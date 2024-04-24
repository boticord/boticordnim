import typedefs
import jsony, asyncdispatch, options, httpclient

const
  libAgent* = "BoticordNim/1.0.0"
  baseUrl* = "https://api.boticord.top/v3"

proc handleErrors[T](response: APIResponse[T]) =
  if response.ok == true: return

  var e: BoticordRequestError
  new(e)

  for err in response.errors.get:
    e.errors.add(err)
    e.msg.add($err.code & ": " & err.message & "; ")

  e.msg = e.msg[0..^3]

  raise e

proc apiRequest*[T](url: string; token = "", httpMethod = HttpGet, body = ""): Future[T] {.async.} =
  let client = newAsyncHttpClient(libAgent)

  if token.len > 0: client.headers.add("Authorization", token)
  if body.len > 0: client.headers.add("Content-Type", "application/json")

  let
    response = await client.request(url,
      httpMethod = httpMethod, body = body)
    responseBody = await response.body()
    parsedResponse = responseBody.fromJson(APIResponse[T])

  handleErrors(parsedResponse)


  return parsedResponse.result.get