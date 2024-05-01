import asyncdispatch, httpclient, json, jsony
import helpers, typedefs

proc getSearchToken*(): Future[string] {.async.} =
  ## Get token for search service
  # let
  #   client = newAsyncHttpClient(libAgent)
  #   response = await client.request(baseUrl & "/search-key")

  # return await response.body()

  return "3d927a63dc23d51b01a85a0c13b188c8561bbdd39239d39abaea1ef3a682bdee"

proc searchIndex[T](token, indexName: string;
  query = "", page: Positive = 1, hitsPerPage: Positive = 20, offset: Natural = 0, filter = "", sort = ""): Future[MeiliSearchResponse[T]] {.async.} =
  let
    client = newAsyncHttpClient(libAgent,
      headers = newHttpHeaders({
        "Authorization": "Bearer " & token,
        "Content-Type": "application/json"
      }))
    body = %*{
      "page": page,
      "q": query,
      "hitsPerPage": hitsPerPage
    }

  if filter.len > 0: body["filter"] = newJString(filter)
  if sort.len > 0: body["sort"] = newJString(sort)

  let
    response = await client.request(baseUrl & "/search/indexes/" & indexName & "/search",
      httpMethod = HttpPost, body = $body)
    responseBody = await response.body()

  return fromJson(responseBody, MeiliSearchResponse[T])

proc searchBots*(token: string;
  query = "", page: Positive = 1, hitsPerPage: Positive = 20, offset: Natural = 0, filter = "", sort = ""): Future[MeiliSearchResponse[MeiliIndexedBot]] {.async.} =
  ## Search for bots
  result = await searchIndex[MeiliIndexedBot](token, "bots", query, page, hitsPerPage, offset, filter, sort)

proc searchServers*(token: string;
  query = "", page: Positive = 1, hitsPerPage: Positive = 20, offset: Natural = 0, filter = "", sort = ""): Future[MeiliSearchResponse[MeiliIndexedServer]] {.async.} =
  ## Search for servers
  result = await searchIndex[MeiliIndexedServer](token, "servers", query, page, hitsPerPage, offset, filter, sort)

proc searchComments*(token: string;
  query = "", page: Positive = 1, hitsPerPage: Positive = 20, offset: Natural = 0, filter = "", sort = ""): Future[MeiliSearchResponse[MeiliIndexedComment]] {.async.} =
  ## Search for comments
  result = await searchIndex[MeiliIndexedComment](token, "comments", query, page, hitsPerPage, offset, filter, sort)