import ../boticordnim/[notifications, typedefs]
import asyncdispatch, os

let
  token = getEnv("BOTICORD_TOKEN")
  notifier = newBoticordNotificator(token)

proc commentEdited(data: WebsocketNotifyData[CommentEditedPayload]) {.event(notifier).} =
  echo data

waitFor notifier.connect()