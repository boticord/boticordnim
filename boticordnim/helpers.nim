from typedefs import BoticordRequestError, ErrorCode, RequestError
import asyncdispatch, httpclient, json

const
  libAgent* = "BoticordNim/1.0.5"
  baseUrl* = "https://api.boticord.top/v3"

proc handleErrors(response: JsonNode) =
  if response["ok"].getBool() == true: return

  var e: BoticordRequestError
  new(e)

  for err in response["errors"].getElems():
    let errorValue = RequestError(code: ErrorCode(err["code"].getInt()), message: err["message"].getStr())
    e.errors.add(errorValue)
    e.msg.add(errorValue.message & " (" & $errorValue.code & ")" & "; ")

  e.msg = e.msg[0..^3]

  raise e

proc apiRequest*(url: string; token = "", httpMethod = HttpGet, body = ""): Future[JsonNode] {.async.} =
  let client = newAsyncHttpClient(libAgent)

  if token.len > 0: client.headers.add("Authorization", token)
  if body.len > 0: client.headers.add("Content-Type", "application/json")

  let
    response = await client.request(url,
      httpMethod = httpMethod, body = body)
    responseBody = await response.body()
    parsedResponse = parseJson(responseBody)

  handleErrors(parsedResponse)

  return parsedResponse["result"]