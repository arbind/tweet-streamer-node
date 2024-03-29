rateLimitWindowDuration = 15 # in minutes https://dev.twitter.com/docs/rate-limiting/1.1/limits
rateLimitRequestsPerWindow = 15
pollFrequencyINms = 1000*60*Math.floor(rateLimitRequestsPerWindow / rateLimitWindowDuration) # ms to wait for polling
pollFrequencyINms = pollFrequencyINms + 8800 # add a buffer of 8.8 seconds to make sure we don't poll too early

class StreamerService extends ServiceBase
  _instance = undefined
  @singleton: () -> _instance ?= new StreamerService

  # ORM
  # call back errors
  @NO_STREAMER_ID: new Error 'No Twitter ID For Streamer!'
  @NO_SCREEN_NAME: new Error 'No Twitter Screen Name For Streamer!'

  # redis keys
  @prefix = "streamer"  # prefix for set of all streamers
  @idKey:        (streamer_id)=> "#{@prefix}:#{streamer_id}"
  @streamerKey:  (streamer)=> @idKey streamer.id()
  @streamerFriendsKey:  (streamer)=> "friends:" + streamer.id()

  @save: (streamer, callback)->
    unless streamer?
      callback(null, false) if callback?
      return false 
    try 
      streamerKey = (@streamerKey streamer)
      redis.set streamerKey, streamer.toJSON(), (err, ok)->
        (callback err, ok) if callback?
      return true
    catch exception
      console.log "exception #{exception} ."
      logError exception
      (callback exception) if callback?
      false

  @destroy: (streamer, callback)=>
    unless streamer
      callback(null, false) if callback?
      return false
    try 
      streamerKey = (@streamerKey streamer)
      return redis.del streamerKey, (err, ok)->
        callback(null, false) if callback?
    catch ex
      logError ex
      (callback ex) if callback?
      return false

  @find: (streamer, callback )=>
    id = streamer if isString(streamer) or isNumber(streamer)
    id ||= streamer.id() if streamer instanceof Streamer
    id ||= streamer.id if streamer.isHash()
    throw 'id is required to find a Streamer' unless id?

    tid = (parseInt id.toString(), 10) # convert string or numeric id to string first then parse in base 10
    StreamerService.findById tid, callback

  @saveFriendIds: (streamer, friendList , callback) ->
    # console.log "saving #{friendList.length} friends for #{streamer.screenName()}"
    @_saveArrayForKey (@streamerFriendsKey streamer), friendList, callback

  @findFriendIds: (streamer, callback) ->
    @_findArrayForKey (@streamerFriendsKey streamer), callback

  @findById: (id, callback )->
    ( return callback(@NO_STREAMER_ID, null) )unless id? # check that args are given
    StreamerService._findObjectForKey Streamer, (@idKey id), callback

  @findAll: (callback)->
    redis.keys @prefix + ':*', (err, streamerKeys) ->
      return callback(err) if err?
      return callback(null, []) unless streamerKeys?.length > 0
      streamers = []
      for key, idx in streamerKeys
        do(key, idx)->
          StreamerService._findObjectForKey Streamer, key, (err, streamer)->
            streamers.push streamer
            callback(null, streamers) if streamers.length is streamerKeys.length

  @findTweets: (screen_name, limit, callback )=> TweetService.findStreamerTweets screen_name, limit, callback

  # Service
  constructor: () ->  
    @StreamerService = @

  @logError = global.logError
  @TwitterClients = {}
  @Poll4NewTweetTimers = {}

  # Cached twitter clients
  @materializeTwitterClient: (streamer) -> 
    twitterClient = @TwitterClients[streamer.id()] || new Twitter(streamer.oauthAccess())
    twitterClient.streamer = streamer
    @TwitterClients[streamer.id()] = twitterClient

  @isStreaming: (streamer)-> @Poll4NewTweetTimers[streamer.id()]?

  @pullAllStreamers: ()->
    @findAll (err, streamers) ->
      return if err? or not streamers?
      # console.log "#{streamers.length} streamers: pull"
      pullMethod = (streamer)-> streamer.pull()
      for streamer, idx in streamers
        setTimeout pullMethod, idx*333, streamer # give each pull a few ms before starting the next pull

  @startStreamingAllStreamers: ()->
    @findAll (err, streamers) ->
      # console.log "#{streamers.length} streamers: startStreaming "
      return if err? or not streamers?
      streamer.startStreaming() for streamer in streamers

  @streamingCount = 0 # number of streamers that have started
  @startStreaming: (streamer) ->
    return unless streamer? # null account
    return if @Poll4NewTweetTimers[streamer.id()]?

    streamLauncher = (streamer)=>
      pollMethod = ()=> @emitNewTweets(streamer)
      int = (setInterval pollMethod, pollFrequencyINms)
      @Poll4NewTweetTimers[streamer.id()] = int
      pollMethod()

    # ensure all streamers don't all start at once if multiple calls to startStreaming are made at 'one' time
    @streamingCount = @streamingCount + 1
    waitPeriod = @streamingCount * 288  # the more streams that have launched, the longer the waitPeriod to start a new stream
    setTimeout streamLauncher, waitPeriod, streamer # launch the stream pollMethod after some waitPeriod in ms
    # console.log "launching stream for #{streamer.screenName()} in #{waitPeriod}ms"

  @stopStreaming: (streamer) ->
    return unless streamer? # null account
    return unless @Poll4NewTweetTimers[streamer.id()]?
    int = @Poll4NewTweetTimers[streamer.id()]
    delete @Poll4NewTweetTimers[streamer.id()]
    clearInterval(int)

  @emitNewTweets: (streamer)->
    streamer.fetchNewTweets (err, tweets) =>
      return @singleton().emit('error', err, streamer.screenName(), streamer.location()) if err # emit error
      # console.log "#{streamer.screenName()}: no new tweets" if !tweets or 0==tweets.length
      return if !tweets or 0==tweets.length
      tweet.emitTo(@singleton()) for tweet in tweets

module.exports = StreamerService