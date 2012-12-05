class Streamer extends ModelBase
  Service: StreamerService

  @materialize: (id, screenName, oauthAccess, callback) ->
    tid = (parseInt id)
    @findById tid, (err, streamer)->
      return (callback err) if err?
      streamer = new Streamer unless streamer?
      streamer.init tid, screenName, oauthAccess
      callback null, streamer

  # finders
  @find: (info, callback)-> (StreamerService.find info, callback)
  @findById: (id, callback )->  (StreamerService.findById id, callback)
  @findAll: (callback) -> StreamerService.findAll(callback)

  init: (id, screenName, oauthAccess) =>
    @set 'id', id
    @set 'screen_name', screenName
    @set 'oauth_access', oauthAccess

  isStreaming: ()=>StreamerService.isStreaming(@)
  startStreaming: ()=> StreamerService.startStreaming(@)

  findFriendIds: (callback)=> 
    (StreamerService.findFriendIds @, callback)

  saveFriendIds: (friendList, callback)=> 
    (StreamerService.saveFriendIds @, friendList, callback)

  # convenient accessors
  screenName:     ()=> (@get 'screen_name')
  location:       ()=> (@get 'location')
  description:    ()=> (@get 'description')
  followersCount: ()=> (@get 'followers_count')
  friendsCount:   ()=> (@get 'friends_count')
  timeZone:       ()=> (@get 'time_zone')
  utcOffset:      ()=> (@get 'utc_offset')
  lang:           ()=> (@get 'lang')

  lastTweetId: ()=> (@get 'last_tweet_id')
  saveLastTweetId: (tweetId)=>
    @set 'last_tweet_id', tweetId
    @save()

  twitterClient: ()=>
    return @_twitterClient if @_twitterClient?
    @_twitterClient = StreamerService.materializeTwitterClient(@)

  oauthAccess: ()=> 
    oauth = (@get 'oauth_access')
    return {} unless oauth?
    consumer = TwitterConsumers[oauth.app]
    return {} unless consumer?
    authorization =  # derived the required oauth access
      consumer_key: consumer.key
      consumer_secret: consumer.secret
      access_token_key: oauth.token
      access_token_secret: oauth.secret      

  pull: (callback) =>
    # console.log "pulling #{@screenName()}"
    @fetchUser (err, userInfo) =>
      return callback(err) if err? and callback?()
      return callback(err, null) if not userInfo? and callback?() # make sure we got a userInfo

      fields = ['screen_name', 'location', 'description', 'followers_count', 'friends_count', 'time_zone', 'utc_offset', 'lang']
      @set field, userInfo[field] for field in fields
      @save()
      @fetchFriendIds (err, friendIds) =>
        callback(err) if err? and callback?()
        @saveFriendIds friendIds, (err, ok)=>
          callback(err, @) if callback?()

  fetchUser: (callback) => @twitterClient().lookupUser @id(), (err, userInfoList)=>
    userInfo = null
    (userInfo = user if "#{user.id}" is "#{@id()}" ) for user in userInfoList
    callback(err, userInfo)

  fetchFriendIds: (callback) =>
    # console.log "#{@screenName()}: fetchFriendIds"
    @twitterClient().getFriendsIds callback

  fetchNewTweets: (callback) =>
    # console.log "#{@screenName()}: fetchNewTweets"
    params = count: 25 # max tweets to retrieve
    since_id = @lastTweetId()
    params.since_id = since_id if since_id?
    @fetchHomeTimelineTweets(params, callback)

  fetchHomeTimelineTweets: (params={}, callback) =>
    @twitterClient().getHomeTimeline params, (err, tweetList) => # https://dev.twitter.com/docs/api/1.1/get/statuses/home_timeline
      return callback(err) if err # emit error

      tweetDataList = []
      # remove the last tweet, which sometimes comes through again (twitter bug?)
      (tweetDataList.push t if t.id isnt @lastTweetId() ) for t in tweetList if tweetList? and tweetList.length>0

      console.log "#{@screenName}: no new tweets" if 0 is tweetDataList.length
      return callback(null, []) if 0 is tweetDataList.length

      @saveLastTweetId tweetDataList[0].id # mark the most recent tweet id, on the next poll we can retrieve new tweets since this id
      tweetList = @saveTweets(tweetDataList)
      callback(null, tweetList)

  saveTweets: (tweetDataList) -> # also trim them for only fieds that we need
    tweetDataList = [ tweetDataList... ] # list of tweet data hashes

    tweets = [] # final result of tweet objects
    for tweetData in tweetDataList
      # console.log tweetData # to see all availalbe fields

      # save the new tweet
      tw = new Tweet tweetData
      tw.setStreamer @
      tw.save()
      tweets.push tw
    tweets

module.exports = Streamer
