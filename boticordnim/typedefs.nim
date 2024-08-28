import options, asyncdispatch
from ws import WebSocket

type
  APIResponse*[T] = object
    ok*: bool
    errors*: Option[seq[RequestError]]
    result*: Option[T]
  RequestError* = object
    code*: ErrorCode
    message*: string
  BoticordRequestError* = ref object of CatchableError
    errors*: seq[RequestError]
  ErrorCode* = enum
   ecInternalServerError
   ecRateLimited
   ecNotFound
   ecForbidden
   ecUnauthorized
   ecBadRequest
   ecRpcError
   ecWsError
   ecUnknownError
   ecThirdPartyFail
   ecUnknownUser
   ecShortLinkTaken
   ecUnknownShortDomain
   ecUnknownLibrary
   ecTokenInvalid
   ecUnknownResource
   ecUnknownTag
   ecPermissionDenied
   ecUnknownComment
   ecUnknownBot
   ecUnknownServer
   ecUnknownBadge
   ecUserAlreadyHasABadge
   ecInvalidInviteCode
   ecServerAlreadyExists
   ecBotNotPresentOnQueueServer
   ecUnknownUp
   ecTooManyUps
   ecInvalidStatus
   ecUnknownReport
   ecUnsupportedMediaType
   ecUnknownApplication
   ecAutomatedRequestsNotAllowed
   ecInvalidRating
   ecDuplicateBot
   ecCannotDetectIp
   ecThirdPartyMonitoringFail
   ecThirdPartyMonitoringNotApproved
   ecTurnstileError
   ecServiceConfiguredIncorrectly
   ecUnknownBoost
   ecBoostExpired
   ecAlreadyCommented
   ecReviewRatingsConflict
   ecTooManyConsecutiveMessages
   ecNoServiceBot
   ecAlreadyReported
   ecCannotDeleteOwner
   ecBlockedBot
   ecUnknownAutomation
   ecOnlyOwnerCanAddServer
   ecReviewReported
   ecLowPremiumLevel
   ecCaptchaServiceUnavailable
   ecInvalidCaptchaAnswer
   ecResourceNotOwned
   ecResourceFetchTimeout
   ecCannotFetchOwner
   ecTooManyCaptchaAttempts
   ecEmptyReview
  ResourceStatus* = enum
    rsHidden
    rsPublic
    rsBanned
    rsPending
  BotTag* = enum
    btModeration
    btCombine
    btUtil
    btFun
    btMusic
    btEconomy
    btLogs
    btLevels
    btNSFW
    btCustomizable
    btRolePlay
    btMemes
    btGames
    btAI
  BotLibrary* = enum
    blDiscord4J = 1
    blDiscordcr
    blDiscordGO
    blDiscordoo
    blDSharpPlus
    blDiscordJs
    blDiscordDotNet
    blDiscordPy
    blEris
    blJavacord
    blJDA
    blOther
  UserLinkType* = enum
    ultVk
    ultTelegram
    ultDonate
    ultGit
    ultCustom
  ServerTag* = enum
    stChatting = 130
    stFun
    stGames
    stMovies
    stAnime
    stArt
    stProgramming
    stMusic
    stNSFW
    stRolePlay
    stHumor
    stGenshin = 160
    stMinecraft
    stGTA
    stCS
    stDota
    stAmongUs
    stFortnite
    stBrawlStars

  UserBadge* = object
    id*: int
    name*, assetURL*: string

  UserSocials* = object
    vk*, git*, telegram*, donate*, custom*: Option[string]
  PartialUser* = ref object of RootObj
    username*, discriminator*, id*: string
    avatar*, description*, shortDescription*: Option[string]
    socials*: UserSocials
  UserProfile* = ref object of PartialUser
    badges*: seq[UserBadge]
    bots*: seq[ResourceBot]
    servers*: seq[ResourceServer]

  PremiumFeature* = enum
    pfUpMultiplierOne = "up_multiplier_one"
    pfAutoFetch = "fetch"
    pfVanityInvite = "vanity_invite"

    pfUpMultiplierTwo = "up_multiplier_two"
    pfSplash = "splash"
    pfBanner = "banner"

    pfUpMultiplierThree = "up_multiplier_three"
    pfVanityUrl = "vanity_url"
    pfUpBot = "up_bot"

    pfInfiniteVanityUrl = "infinite_vanity_url"
  PremiumResourceFeatures* = ref object
    active*, autoFetch*: bool
    splashURL*, bannerURL*, vanityInvite*, vanityURL*: Option[string]
    features*: seq[PremiumFeature]

  NotifySettings* = ref object
    enabled*: bool

  UpEntity* = ref object
    id*, expires*: string

  ResourceRating* = object
    count*: int
    rating*: range[1 .. 5] = 1
  BaseResourceEntity* = ref object of RootObj
    id*, name*, shortDescription*, description*, inviteLink*, owner*, lastFetch*: string
    avatar*, website*: Option[string]
    standardBannerID*, upCount*: int
    showDefaultBanner*: Option[bool]
    status*: ResourceStatus
    ratings*: seq[ResourceRating]
    premium*: PremiumResourceFeatures
    reviewsActionsDisabled*: bool
    ups*: Option[seq[UpEntity]]
  ResourceBot* = ref object of BaseResourceEntity
    prefix*, discriminator*, createdDate*: string
    supportServerInviteCode*: Option[string]
    developers*: seq[PartialUser]
    library*: Option[BotLibrary]
    guilds*, members*, shards*: Option[int]
    tags*: seq[BotTag]
    notify*: Option[NotifySettings]
  ResourceServer* = ref object of BaseResourceEntity
    memberCount*: int
    bannerURL*, banner*: Option[string]
    createdDate*: string
    tags*: seq[ServerTag]
    moderators*: seq[PartialUser]
  
  MeiliSearchResponse*[T] = object
    hits*: seq[T]
    query*: string
    hitsPerPage*, page*, totalPages*, totalHits*: int
  MeiliIndexedBot* = ref object
    id*, name*, description*, shortDescription*, invite*: string
    avatar*: Option[string]
    ups*, banner*: int
    rating*: float
    guilds*: Option[int]
    tags*: seq[BotTag]
  MeiliIndexedServer* = ref object
    id*, name*, description*, shortDescription*, invite*: string
    avatar*, discordBanner*: Option[string]
    ups*, rating*, banner*: int
    members*: Option[int]
    tags*: seq[ServerTag]
  MeiliIndexedComment* = ref object
    id*, author*, content*, resource*, created*, modReply*: string
    rating*: int

  UpAddedPayload* = object
    upCount*: float
  CommentAddedPayload* = object
    content*: string
    rating*: int
  CommentEditedPayload* = CommentAddedPayload
  CommentRemovedPayload* = CommentAddedPayload

  WebsocketNotifyType* = enum
    UpAdded = "up_added"
    ReviewAdded = "comment_added"
    ReviewEdited = "comment_edited"
    ReviewRemoved = "comment_removed"
  WebsocketNotifyData*[T] = object
    `type`*: WebsocketNotifyType
    id*, user*: string
    happened*: int
    payload*: T
  WebsocketSendEvent* = enum
    wsePing = "ping"
    wseAuth = "auth"
  WebsocketReceiveEvent* = enum
    wreHello = "hello"
    wrePong = "pong"
    wreNotify = "notify"
  WebsocketPacket*[T] = object
    event*: WebsocketSendEvent
    data*: T
  WebsocketAuthData* = object
    token*: string
  BoticordNotifyEvent*[T] = proc(data: WebsocketNotifyData[T]) {.async.}
  NotificatorEvents* = ref object
    up_added*: BoticordNotifyEvent[UpAddedPayload]
    comment_added*: BoticordNotifyEvent[CommentAddedPayload]
    comment_edited*: BoticordNotifyEvent[CommentEditedPayload]
    comment_removed*: BoticordNotifyEvent[CommentRemovedPayload]
  BoticordNotificator* = ref object
    token*: string
    connection*: WebSocket
    stop*: bool
    events*: NotificatorEvents