<p align="center">
    <img src="https://cdn.boticord.top/internal/github/boticord-nim.svg" width="560">
</p>

<p align="center">
    Utility for interaction with Boticord API on Nim
</p>

[API Reference](https://boticord.github.io/boticordnim/)

## Installation

Enter this command to install package
```
nimble install https://github.com/boticord/boticordnim
```

Or add `"https://github.com/boticord/boticordnim"` in your nimble `requires`

If you encounter a problem that application can't find a hook for optional values, then add `-d:defineOptionHook` during compilation

## Examples

Get info from some resources

```nim
import boticordnim/[bots, users, servers]
import asyncdispatch, strformat

let
  botId = "974297735559806986"
  bot = waitFor getBot(botId) # or getBot(id = botId)
  
  serverId = "992158889116180502"
  server = waitFor getServer(serverId)
  
  userId = "267729391172321290"
  user = waitFor getUser(userId)

echo fmt"Name of {botId} resource (bots): {bot.name}"
echo fmt"Name of {serverId} resource (servers): {server.name}"
echo fmt"Name of {userId} resource (users): {user.username}"
```

Other examples are located in [examples folder](/examples)