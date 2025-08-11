import std/[times, strutils, strformat]
import defs

const nano_sec* = 1_000_000_000

proc toNanoSecs*(delta: TimeDelta): int64 =
  var cumm = delta.count
  if delta.period == Nano:
    return cumm
  cumm *= 1_000
  if delta.period == Micro:
    return cumm
  cumm *= 1_000
  if delta.period == Milli:
    return cumm
  cumm *= 1_000
  if delta.period == Sec:
    return cumm
  cumm *= 60
  if delta.period == Min:
    return cumm
  cumm *= 60
  if delta.period == Hour:
    return cumm
  cumm *= 24
  if delta.period == Day:
    return cumm
  raise newException(Exception, "Time delta are defined up to days")

proc getCurrentTime*(): int64 {.inline.} =
  let current = getTime().toUnixFloat()
  result = int64(current * nano_sec)

proc fromISODate(ts: string): int64 =
  try:
    let format = "yyyy-MM-dd"
    let dt = parse(ts, format, utc())
    return int64(dt.toTime.toUnix * 1_000_000_000)
  except Exception as e:
    raise newException(Exception, fmt"Date cannot be converted to epoch ns: {ts}\n" & e.msg)

proc fromISODateTime(ts: string): int64 =
  try:
    let format = "yyyy-MM-dd'T'HH:mm:ss"
    let dt = parse(ts, format, utc())
    return int64(dt.toTime.toUnix * 1_000_000_000)
  except Exception as e:
    raise newException(Exception, fmt"DateTime cannot be converted to epoch ns: {ts}\n" & e.msg)

proc fromISOString*(ts: string): int64 =
  try:
    if ts.len == 10:
      return fromISODate(ts)
    elif ts.len == 19:
      return fromISODateTime(ts)
    elif ts.len > 20 and ts[19] == '.':
      let base = ts[0..18]
      let frac = ts[20..^1]
      let dt = fromISODateTime(base)
      let pad = frac.alignLeft(9, '0')
      let ns = parseBiggestUInt(pad)
      return dt + int64(ns)
    else:
      raise newException(Exception, "Parsing not implemented")
  except Exception as e:
    raise newException(Exception, "Datetime parser failure ")

proc toISOString*(epoch_ns: int64): string =
  let
    secs = epoch_ns div 1_000_000_000
    rem = int(epoch_ns mod 1_000_000_000)
    time = fromUnix(int64(secs)).utc
    iso = time.format("yyyy-MM-dd'T'HH:mm:ss") & "." &
          ($rem).align(count=9, padding='0') & "Z"
  result = iso
