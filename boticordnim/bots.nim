import asyncdispatch, httpclient, json, options
from typedefs import ResourceBot
import helpers

proc getBot*(id: string, token = ""): Future[ResourceBot] {.async.} =
  ## Get information about the bot
  result = await apiRequest[ResourceBot](url =  baseUrl & "/bots/" & id,
    token = token)

proc postBotStats*(token, id: string;
  servers, shards, members = none int): Future[ResourceBot] {.async.} =
  ## Post statistics information for the bot
  var body = %*{}

  if members.isSome: body["members"] = newJInt(members.get)
  if servers.isSome: body["servers"] = newJInt(servers.get)
  if shards.isSome: body["shards"] = newJInt(shards.get)

  doAssert body.len != 0

  result = await apiRequest[ResourceBot](baseUrl & "/bots/" & id & "/stats",
    token, HttpPost, $body)