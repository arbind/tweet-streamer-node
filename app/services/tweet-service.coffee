class TweetService extends ServiceBase
  @logError = global.logError

  # call back errors
  @NO_TWEET_ID: new Error 'No Tweet ID!'
  @NO_SCREEN_NAME: new Error 'No Twitter Screen Name!'
  @NO_STREAMER: new Error 'No Twitter Screen Name for Streamer !'

  # redis time to live
  # @ttl = 3*60*60*24 # 3 days
  # @setTTL: (time_limit)-> TweetService.ttl = time_limit if time_limit

  @MAX_USER_TWEETS = 10

  # redis keys
  @w = "w" # prefix for set of all tweets
  @idKey:          (tweet_id)=> "t:#{tweet_id}"
  @tweetKey:          (tweet)=> @idKey tweet.id()
  @userKey:     (screen_name)=> "u:#{screen_name}"
  @streamerKey: (screen_name)=> "s:#{screen_name}"
  @allTweetsKey:           ()=> @w

  @tweetCount: (callback)=>
    redis.zcard @allTweetsKey(), callback

  @save: (tweet)=>
    return false unless tweet
    try
      # console.log "Tweet.toJSON()"
      # console.log tweet.toJSON()
      # console.log "Tweet.toEvent()"
      # console.log tweet.toEvent()
      # console.log "Tweet"
      # console.log tweet
      tweetKey = (@tweetKey tweet)
      score = 0 - Date.now()                                                      # score in reverse chronological order
      redis.set tweetKey, tweet.toJSON()                                          # save tweet by tweet id
      redis.zadd (@userKey tweet.screenName()), score, tweet.id()                 # save tweet id to user
      redis.zadd (@streamerKey tweet.streamer().screenName()), score, tweet.id()     # save tweet id to streamer
      redis.zadd @allTweetsKey(), score, tweet.id()                               # save tweet id to all tweets
      (@_pruneTweets tweet.screenName())                                          # prune tweets asynchronously
      true
    catch exception
      logError exception
      false

  @findTweet: (tweet_id, callback )=>
    unless tweet_id # check that args are given
      callback(@NO_TWEET_ID, null); return
    @_findTweetForKey (@idKey tweet_id), callback

  @findUserTweets: (screen_name, limit, callback )=>
    (callback = limit; limit = 10) if "function" is typeof limit # default limit=10 for user, assume last arg is the callback
    unless screen_name # check that args are given
      callback(@NO_SCREEN_NAME, null); return
    @_dereferenceTweetsForZKey (@userKey screen_name), limit, callback

  @findStreamerTweets: (streamer_screen_name, limit, callback )=>
    (callback = limit; limit = 100) if "function" is typeof limit # default limit=100 for streamer, assume last arg is the callback
    unless streamer_screen_name # check that args are given
      callback(@NO_STREAMER, null); return
    @_dereferenceTweetsForZKey (@streamerKey streamer_screen_name), limit, callback

  @findAllTweets: (limit, callback )=>
    (callback = limit; limit = 100) if "function" is typeof limit # default limit=100 for streamer, assume last arg is the callback
    @_dereferenceTweetsForZKey @allTweetsKey(), limit, callback

  @destroy: (tweets...)=>
    return unless tweets
    for tweet in tweets
      try 
        tweetKey = (@tweetKey tweet)
        redis.del  tweetKey                                                    # remove tweet
        redis.zrem (@userKey tweet.screenName()), tweet.id()                   # remove tweet ref from user
        redis.zrem (@streamerKey tweet.streamer().screenName()), tweet.id()    # remove tweet ref from streamer
        redis.zrem @allTweetsKey(), tweet.id()                                 # remove tweet ref from all tweets
      catch exception
        logError exception

  # sort of private methods

  # finders
  @_findTweetForKey: (key, callback )=>
    redis.get key, (err, json_string)=>
      result = null;
      try 
        result = @_tweetFromJSON(json_string)
      catch exception
        err = @logError 'TweetService @_findTweetForKey: \n', exception
      finally
        (callback err, result)

  @_dereferenceTweetsForZKey: (zkey,limit, callback)=>
    @_findTweetRefsForZKey zkey, limit, (err, tweet_id_refs)=>
      return (callback err) if err
      return (callback null, []) unless tweet_id_refs and 0<tweet_id_refs.length

      tweetKeys  = ((@idKey tweet_id) for tweet_id in tweet_id_refs) # map tweet_id to a tweet key (t:tweet_id)
      redis.mget tweetKeys, (err, jsonArray)=>
        resultList = []
        try
          resultList = @_tweetsFromJSONArray jsonArray
        catch exception
          err = @logError 'TweetService @_dereferenceTweetsForZKey:', exception
        finally
          (callback err, resultList)

  @_findTweetRefsForZKey: (zkey, limit, callback)=>
    end = limit # number to retrieve or 0 to get all
    end = 0 if limit < 0 # default to 0 (get all) if < 0
    end = end-1 #  [0.. (limit-1)] (to get limit) or [0..-1] (to get all)
    redis.zrange zkey, 0, end, callback

  # de-serialization
  @_tweetFromJSON: (json_string)=> # throws exception if json can not be parsed
    return null unless json_string
    tweet = new Tweet JSON.parse(json_string)
      
  @_tweetsFromJSONArray: (jsonArray)=>
    resultList = []
    return resultList unless jsonArray
    for json_string in jsonArray
      tweet = (@_tweetFromJSON json_string) if json_string?
      resultList.push tweet if tweet?
    resultList

  @_pruneTweets: (screen_name) =>
    return unless screen_name
    @findUserTweets screen_name, 0, (err, tweetList)=>
      return unless tweetList
      numTweets = tweetList.length
      return if @MAX_USER_TWEETS > numTweets
      idx = @MAX_USER_TWEETS - 1
      tweetList[idx]?.destroy() while idx++ < numTweets

module.exports = TweetService