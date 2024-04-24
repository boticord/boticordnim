import ../boticordnim/[bots, typedefs]
import asyncdispatch, os, options

let
  token = getEnv("BOTICORD_TOKEN")
  botId = "974297735559806986"
  serverCount = 77777
  shards = 40

asyncCheck postBotStats(token = token, id = botId, servers = some serverCount, shards = some shards)