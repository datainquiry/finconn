import std/[strutils, re, parseopt, asyncdispatch, json]
import history/[yfinance, defs, timeutil]

type
  Args = object
    request: HistoryRequest

proc showHelp() =
  echo "Usage: finconn [OPTIONS] --symbol:SYMBOL"
  echo "Options:"
  echo "  --help: This help"
  echo "  --start or -s: Start time"
  echo "  --end or -e: End time"
  echo "  --interval: Interval of time for aggregation"
  echo "Times should written as: yyyy-mm-dd or yyyy-mm-ddTHH:MM"
  echo "Valid intervals are: Min, Hour, and Day."
  echo "Output is in JSON format."
  echo "Output times are expressed as nanoseconds from epoch."

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
  for kind, key, val in getopt():
    case kind
    of cmdLongOption, cmdShortOption:
      case key
      of "help", "h":
        showHelp()
        quit(0)
      of "start", "s":
        start = val
      of "end", "e":
        finish = val
      of "symbol":
        if val.len != 0:
          symbol = val
      of "interval":
        interval = val
      else:
        echo "Unknown option: --", key
        quit(1)
    else: discard
  try:
    start = parseTimeStamp(start)
    finish = parseTimeStamp(finish)
    let freq = parseEnum[Period](interval[0].toUpperAscii & interval[1..^1].toLowerAscii)
    if not (freq in @[Min, Hour, Day]):
      raise newException(Exception, "Interval should be min, hour, or day")
    if symbol.len == 0:
      raise newException(Exception, "Symbol should be defined")
    result = Args(
      request: HistoryRequest(
        symbol: symbol.toUpper,
        start_time: fromISOString(start),
        end_time: fromISOString(finish),
        freq: freq
      )
    )
  except Exception as e:
    raise newException(Exception, "Error building request\n" & e.msg)

when isMainModule:
  let args = parseArgs()
  let history = waitFor pullHistory(args.request)
  echo $(%*history)

