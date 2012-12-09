class Streamer extends ModelBase
  Service: StreamerService
  privateFields:    [ 'oauth_access' ]
  classFieldNames:  [ 'id'
                    , 'name'
                    , 'screen_name'
                    , 'description'
                    , 'location'
                    , 'oauth_access'
                    , 'lang'
                    , 'followers_count'
                    , 'friends_count'
                    , 'time_zone'
                    , 'utc_offset'
                    # , 'profile_image_url'
                    ]

  @materialize: (attributes, consumer_app_name, oauth_access_token, oauth_access_token_secret, callback) ->
    @find attributes, (err, streamer)->
      return (callback err) if err?
      s = streamer || new Streamer attributes, consumer_app_name, oauth_access_token, oauth_access_token_secret
      callback null, s

  # finders
  @find: (info, callback)-> (StreamerService.find info, callback)
  @findById: (id, callback )->  (StreamerService.findById id, callback)
  @findAll: (callback) -> StreamerService.findAll(callback)

  constructor: (attributes, consumer_app_name, oauth_access_token, oauth_access_token_secret) ->
    atts = {}
    atts.inject attributes
    if consumer_app_name?
      atts.oauth_access =
        app: consumer_app_name
        token: oauth_access_token
        secret: oauth_access_token_secret
    super(atts)

  oauthAccess: ()=> 
    oauth = (@get 'oauth_access')
    return {} unless oauth?
    consumer = TwitterConsumers[oauth.app]
    throw "No consumer app named '#{oauth.app}'" unless consumer?
    authorization =  # derived the required oauth access
      consumer_key: consumer.key
      consumer_secret: consumer.secret
      access_token_key: oauth.token
      access_token_secret: oauth.secret

  # convenient accessors
  screenName:       ()=> (@get 'screen_name')
  name:             ()=> (@get 'name')
  description:      ()=> (@get 'description')
  location:         ()=> (@get 'location')
  followersCount:   ()=> (@get 'followers_count')
  friendsCount:     ()=> (@get 'friends_count')
  timeZone:         ()=> (@get 'time_zone')
  utcOffset:        ()=> (@get 'utc_offset')
  language:         ()=> (@get 'lang')

  # optional attributes removed to trim DB size
  
  # profileImageURL:  ()-> (@get 'profile_image_url')


  isStreaming: ()=>StreamerService.isStreaming(@)
  startStreaming: ()=> StreamerService.startStreaming(@)

  findFriendIds: (callback)=> 
    (StreamerService.findFriendIds @, callback)

  saveFriendIds: (friendList, callback)=> 
    (StreamerService.saveFriendIds @, friendList, callback)

  lastTweetId: ()=> (@get 'last_tweet_id')
  saveLastTweetId: (tweetId)=>
    @set 'last_tweet_id', tweetId
    @save()

  twitterClient: ()=>
    return @_twitterClient if @_twitterClient?
    @_twitterClient = StreamerService.materializeTwitterClient(@)

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
