import asyncdispatch, json, asyncnet, macros, sugar, strutils
import ws, jsonyy
import typedefs

const gatewayUrl = "wss://gateway.boticord.top/websocket"

proc newBoticordNotificator*(token: string): BoticordNotificator =
  ## Creates new Notificator instance
  result = BoticordNotificator(
    token: token,
    events: NotificatorEvents(
      up_added: proc(data: WebsocketNotifyData[UpAddedPayload]) {.async.} = discard,
      comment_added: proc(data: WebsocketNotifyData[CommentAddedPayload]) {.async.} = discard,
      comment_edited: proc(data: WebsocketNotifyData[CommentEditedPayload]) {.async.} = discard,
      comment_removed: proc(data: WebsocketNotifyData[CommentRemovedPayload]) {.async.} = discard
    )
  )

proc identify(n: BoticordNotificator) {.async.} =
  let packet = WebsocketPacket[WebsocketAuthData](
    event: wseAuth,
    data: WebsocketAuthData(token: n.token)
  )

  await n.connection.send(packet.toJson())

proc closed(n: BoticordNotificator): bool =
  return n.connection == nil or n.connection.tcpSocket.isClosed or n.stop

proc ping(n: BoticordNotificator) {.async.} =
  let packet = WebsocketPacket[void](
    event: wsePing
  )

  await n.connection.send(packet.toJson())

# proc sendStats

macro callEvent(n: BoticordNotificator, event: static[WebsocketNotifyType], args: varargs[untyped]) =
  let params = collect:
    for arg in args: arg

  let
    eventName = ident toLowerAscii($event)
    call = n.newDotExpr(ident"events")
                             .newDotExpr(eventName)
                             .newCall(params)
  result = quote do:
    asyncCheck `call`

proc close*(n: BoticordNotificator) =
  n.stop = true
  n.connection.close()

proc handleMessages(n: BoticordNotificator) {.async.} =
  while not n.closed:
    let
      packet = await n.connection.receiveStrPacket()
      data = parseJson(packet)

    case data["event"].getStr():
      of "error":
        if data["data"]["code"].getInt() == 6:
          n.close()
          raise newException(CatchableError, "Invalid token")
      of "notify":
        case data["data"]["type"].getStr():
        of "up_added":
          let eventData = fromJson($data["data"], WebsocketNotifyData[UpAddedPayload])
          n.callEvent(UpAdded, eventData)
        of "comment_added":
          let eventData = fromJson($data["data"], WebsocketNotifyData[CommentAddedPayload])
          n.callEvent(ReviewAdded, eventData)
        of "comment_edited":
          let eventData = fromJson($data["data"], WebsocketNotifyData[CommentEditedPayload])
          n.callEvent(ReviewEdited, eventData)
        of "comment_removed":
          let eventData = fromJson($data["data"], WebsocketNotifyData[CommentRemovedPayload])
          n.callEvent(ReviewRemoved, eventData)
        else:
          discard
      else:
        discard

var pingLoop: proc(n: BoticordNotificator) {.async.}
pingLoop = proc(n: BoticordNotificator) {.async.} =
  if n.closed: return
  await n.ping()
  await sleepAsync(60_000)
  await n.pingLoop()

proc connect*(n: BoticordNotificator) {.async.} =
  ## Connect to gateway service and listen messages
  n.stop = false
  n.connection = await newWebSocket(gatewayUrl)
  await n.identify()
  asyncCheck n.pingLoop()
  await n.handleMessages()

macro event*(notificator: BoticordNotificator, fn: untyped): untyped =
  ## Register new listener for event
  let
    eventName = fn[0]
    params = fn[3]
    pragmas = fn[4]
    body = fn[6]

  var anonFn = newTree(
    nnkLambda,
    newEmptyNode(),
    newEmptyNode(),
    newEmptyNode(),
    params,
    pragmas,
    newEmptyNode(),
    body
  )

  if pragmas.findChild(it.strVal == "async").kind == nnkNilLit:
    anonFn.addPragma ident("async")

  result = quote:
    `notificator`.events.`eventName` = `anonFn`
  result[1].copyLineInfo(fn)