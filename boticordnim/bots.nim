import asyncdispatch, httpclient, json, options
from typedefs import ResourceBot
import helpers
import jsony

proc getBot*(id: string, token = ""): Future[ResourceBot] {.async.} =
  ## Get information about the bot
  let apiResponse = await apiRequest(url =  baseUrl & "/bots/" & id,
    token = token)
  result = ($apiResponse).fromJson(ResourceBot)

proc postBotStats*(token, id: string;
  servers = none int; shards = none int; members = none int): Future[ResourceBot] {.async.} =
  ## Post statistics information for the bot
  var body = %*{}

  if members.isSome: body["members"] = newJInt(members.get)
  if servers.isSome: body["servers"] = newJInt(servers.get)
  if shards.isSome: body["shards"] = newJInt(shards.get)

  doAssert body.len != 0

  let apiResponse = await apiRequest(baseUrl & "/bots/" & id & "/stats",
    token, HttpPost, $body)
  result = ($apiResponse).fromJson(ResourceBot)