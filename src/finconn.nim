import std/[strutils, re, parseopt, asyncdispatch, json]
import history/[yfinance, defs, timeutil, serialize]

proc showHelp() =
  echo "Usage: finconn [OPTIONS] --symbol:SYMBOL"
  echo "Options:"
  echo "  -h, --help: This help"
  echo "  -s, --symbol: Asset symbol"
  echo "  --start: Start time"
  echo "  --end: End time"
  echo "  -i, --interval: Interval of time for aggregation"
  echo "  -r, --raw: Times are returned as epoch nanoseconds, otherwise as UTC ISO strings"
  echo "  -f, --format: output format, json or csv"
  echo "Times should written as: yyyy-mm-dd or yyyy-mm-ddTHH:MM"
  echo "Valid intervals are: Min, Hour, and Day."

func parseTimeStamp(ts: string): string =
  let long_pattern = re"^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}$"
  let short_pattern = re"^\d{4}-\d{2}-\d{2}$"
  if not (ts.match(long_pattern) or ts.match(short_pattern)):
    raise newException(Exception, "Invalid timestamp format")
  if ts.len == 16:
    return ts & ":00"
  result = ts


proc parseArgs(): Args =
  let current = getCurrentTime()
  var start = "1990-01-01T00:00"
  var finish = current.toISOString()[0..15]
  var symbol = ""
  var interval = "day" 
  var format = "json"
  var raw = false
  for kind, key, val in getopt():
    case kind
    of cmdLongOption, cmdShortOption:
      case key
      of "help", "h":
        showHelp()
        quit(0)
      of "start":
        start = val
      of "end":
        finish = val
      of "symbol", "s":
        if val.len != 0:
          symbol = val
      of "interval", "i":
        interval = val
      of "raw", "r":
        raw = true
      of "format", "f":
        format = val
      else:
        echo "Unknown option: --", key
        quit(1)
    else: discard
  try:
    start = parseTimeStamp(start)
    finish = parseTimeStamp(finish)
    let freq = parseEnum[Period](interval[0].toUpperAscii & interval[1..^1].toLowerAscii)
    if not (freq in @[Min, Hour, Day]):
      raise newException(ValueError, "Interval should be min, hour, or day")
    let fmt =
      case format
        of "csv": ofCsv
        of "json": ofJson
        else:
          raise newException(ValueError, "Format can only be json or csv")
    if symbol.len == 0:
      raise newException(ValueError, "Symbol should be defined")
    result = Args(
      request: HistoryRequest(
        symbol: symbol.toUpper,
        start_time: fromISOString(start),
        end_time: fromISOString(finish),
        freq: freq
      ),
      rawTime: raw,
      format: fmt
    )
  except Exception as e:
    raise newException(Exception, "Error building request\n" & e.msg)

when isMainModule:
  let args = parseArgs()
  let history = waitFor pullHistory(args.request)
  if args.format == ofJson:
    echo pretty(history.toJson(args.rawTime))
  else:
    echo history.toCsv(args.rawTime)
