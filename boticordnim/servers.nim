import asyncdispatch
from typedefs import ResourceServer
import helpers

proc getServer*(id: string): Future[ResourceServer] {.async.} =
  ## Get information about server
  result = await apiRequest[ResourceServer](baseUrl & "/servers/" & id)