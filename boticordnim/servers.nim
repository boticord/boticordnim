import asyncdispatch
from typedefs import ResourceServer
import helpers

proc getServer*(id: string, token = ""): Future[ResourceServer] {.async.} =
  ## Get information about server
  result = await apiRequest[ResourceServer](url = baseUrl & "/servers/" & id,
    token = token)