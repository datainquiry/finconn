# FinConn - An API connector for finance trading application

This a library to pull market data.

At this moment, it is able to pull historical price data from Yahoo Finance.

Usage: finconn [OPTIONS] --symbol:SYMBOL

Options:

  -h, --help: This help
  -s, --symbol: Asset symbol
  --start: Start time
  --end: End time
  -i, --interval: Interval of time for aggregation
  -r, --raw: Times are returned as epoch nanoseconds, otherwise as UTC ISO strings
  -f, --format: output format, json or csv
  
Times should written as: yyyy-mm-dd or yyyy-mm-ddTHH:MM

Valid intervals are: Min, Hour, and Day.
