import std/[net, httpclient, asyncdispatch]

proc requestGet*(url: string): Future[string] {.async.} =
  when defined(DEBUG):
    echo url
  try:
    let client = newAsyncHttpClient(sslContext=newContext(verifyMode=CVerifyNone))
    let response = await client.get(url)
    if response.status != "200 OK":
      raise newException(Exception, "Invalid response\n" & response.status)
    result = await response.body
  except HttpRequestError as e:
    raise newException(IOError, "Failed on get request\n" & e.msg)
