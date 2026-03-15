import asyncdispatch, jsony, json
from typedefs import ResourceServer
import helpers

proc getServer*(id: string, token = ""): Future[ResourceServer] {.async.} =
  ## Get information about server
  let apiResponse = await apiRequest(url = baseUrl & "/servers/" & id,
    token = token)
  result = ($apiResponse).fromJson(ResourceServer)