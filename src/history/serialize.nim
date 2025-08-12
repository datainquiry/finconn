import std/[json, strutils, strformat, sequtils]
import defs, timeutil

proc toJson*(self: Ohlcv, rawTime: bool = true): JsonNode =
  result = newJObject()
  if rawTime:
    result["time"] = %self.time
  else:
    result["time"] = %toISOString(self.time)
  result["open"] = %self.open
  result["high"] = %self.high
  result["low"] = %self.low
  result["close"] = %self.close
  result["adjclose"] = %self.adjclose
  result["volume"] = %self.volume

proc toJson*(self: seq[Ohlcv], rawTime: bool = true): JsonNode =
  result = newJArray()
  for item in self:
    result.add(item.toJson(rawTime))

proc toCsv*(self: Ohlcv, rawTime: bool = true): string =
  let time =
    if rawTime:
      $self.time
    else:
      toISOString(self.time)
  result = fmt"{time},{self.open},{self.high},{self.low},{self.close},{self.adjclose},{self.volume}"

proc toCsv*(self: seq[Ohlcv], rawTime: bool = true): string =
  let header = "time,open,high,low,close,adjclose,volume"
  let rows = self.map(proc(x: Ohlcv): string = x.toCsv(rawTime))
  result = header & "\n" & rows.join("\n")
