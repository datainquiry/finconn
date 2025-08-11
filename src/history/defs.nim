import std/math

type
  Ohlcv* = object
    time*: int64
    open*: float64
    high*: float64
    low*: float64
    close*: float64
    adjclose*: float64 = NaN
    volume*: float64

  History* = seq[Ohlcv]

  Period* = enum
    Nano, Micro, Milli, Sec, Min, Hour, Day, Week, Month, Year

  Exchange* = enum
    Any

  HistoryRequest* = object
    exchange*: Exchange = Any
    symbol*: string
    start_time*: int64
    end_time*: int64
    freq*: Period = Day

  datetime* = int64

  TimeDelta* = object
    count*: int64
    period*: Period
