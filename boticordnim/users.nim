import asyncdispatch
from typedefs import UserProfile
import helpers

proc getUser*(id: string): Future[UserProfile] {.async.} =
  ## Get user profile
  result = await apiRequest[UserProfile](baseUrl & "/users/" & id)