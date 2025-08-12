import std/[uri, strformat, json, asyncdispatch]
import defs, timeutil, request

const baseUrl = "https://query2.finance.yahoo.com/v8/finance/chart"

proc makeUrl(request: HistoryRequest): string =
  let interval = case request.freq
    of Min: "1m"
    of Hour: "1h"
    of Day: "1d"
    else:
      raise newException(ValueError, "YF available only for min, hour, and day time frames")
  let params = @[
    ("interval", interval),
    ("period1", $int(request.start_time / nano_sec)),
    ("period2", $int(request.end_time / nano_sec)),
  ]
  let query = encodeQuery(params)
  result = fmt"{baseURL}/{request.symbol}?{query}"

proc parseYFResponse(content: string): History =
  let json = content.parseJson
  let res = json["chart"]["result"][0]
  let quote = res["indicators"]["quote"][0]
  let adj = res["indicators"]["adjclose"][0]["adjclose"]
  let n = res["timestamp"].len
  var history = newSeq[Ohlcv](n)
  for i in 0..<n:
    history[i].time = res["timestamp"][i].getInt * nano_sec
    history[i].open = quote["open"][i].getFloat
    history[i].high = quote["high"][i].getFloat
    history[i].low = quote["low"][i].getFloat
    history[i].close = quote["close"][i].getFloat
    history[i].adjclose = adj[i].getFloat
    history[i].volume = quote["volume"][i].getFloat
  result = history

proc pullHistory*(request: HistoryRequest): Future[History] {.async.} =
  try:
    let url = makeUrl(request)
    let content = await requestGet(url)
    result = parseYFResponse(content)
  except Exception as e:
    raise newException(IOError, "Unable to pull history\n" & e.msg)
