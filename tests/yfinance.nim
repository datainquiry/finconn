import std/unittest
include ../src/history/yfinance

when defined(DEBUG):
  suite "YF Tests":
    test "makeUrl":
      let current_time = getCurrentTime()
      let request = HistoryRequest(
        symbol: "IBM",
        start_time: current_time - TimeDelta(count: 30, period: Day).toNanoSecs,
        end_time: current_time
      )
      let url = makeUrl(request)
      echo url

    test "pullHistory":
      let current_time = getCurrentTime()
      let request = HistoryRequest(
        symbol: "IBM",
        start_time: current_time - TimeDelta(count: 30, period: Day).toNanoSecs,
        end_time: current_time
      )
      discard waitFor pullHistory(request)
