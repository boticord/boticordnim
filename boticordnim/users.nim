import asyncdispatch
from typedefs import UserProfile
import helpers

proc getUser*(id: string, token = ""): Future[UserProfile] {.async.} =
  ## Get user profile
  result = await apiRequest[UserProfile](url = baseUrl & "/users/" & id,
    token = token)