import asyncdispatch, httpclient, json, options
from typedefs import ResourceBot
import helpers

proc getBot*(id: string): Future[ResourceBot] {.async.} =
  ## Get information about the bot
  result = await apiRequest[ResourceBot](baseUrl & "/bots/" & id)

proc postBotStats*(token, id: string;
  servers, shards, members = none int): Future[ResourceBot] {.async.} =
  ## Post statistics information for the bot
  var body = %*{}

  if members.isSome: body["members"] = newJInt(members.get)
  if servers.isSome: body["servers"] = newJInt(servers.get)
  if shards.isSome: body["shards"] = newJInt(shards.get)

  assert body.len != 0

  result = await apiRequest[ResourceBot](baseUrl & "/bots/" & id & "/stats",
    token, HttpPost, $body)