import asyncdispatch, jsony, json
from typedefs import UserProfile
import helpers

proc getUser*(id: string, token = ""): Future[UserProfile] {.async.} =
  ## Get user profile
  let apiResponse = await apiRequest(url = baseUrl & "/users/" & id,
    token = token)
  result = ($apiResponse).fromJson(UserProfile)