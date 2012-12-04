YelpLib = require('yelp')

class YelpService
  # class attributes
  @resultsPerPage: 20
  @sessionTTL: 60*60 # 1hr = 60s * 60m
  @bizTTL: 5*60*60   # 5hrs : worst case expiration for a yelp biz, so it doesn't get stale
  @client: (oauthConfig, redisClient)-> new YelpService oauthConfig, redisClient
  @clientAPI: null

  constructor: (@oauthConfig, @redisClient)->
    YelpService.clientAPI ||= YelpLib.createClient @oauthConfig

  # Finding a biz by its yelp-id will cache the biz for the session
  # doesn't seem to work for yelpId with special chars: julios-café-austin-2

  # 4 paths:
  # 1. empty:  biz is not in cache (1st ever search for biz)
  #    request to Yelp is required
  # 2. cached: biz is in cache, and in session (user already searched for biz durring the session)
  #    request to Yelp not required
  # 3. expired biz is in cache, but not in session (user searched for biz before, but the session expired)
  #    request to Yelp is required (return cached biz for performance, then update cache to keep it real-time )
  # 4. shared: biz is in cache, but not in session (1st search for biz by this user, but biz was alreay put in cache from another user)
  #    request to Yelp is required (return cached biz for performance, then update cache to keep it real-time )
  biz: (sessionId, yelpId, callback)=>
    @redisClient.get yelpId, (err, bizJSON)=>
      if err?
        console.log "redis err"
        console.log err
        callback(err)
        return
      if bizJSON?
        console.log "rematerializing #{yelpId} from cache"
        console.log "returning #{yelpId} from cache"
        adaptedBiz = (JSON.parse bizJSON) if bizJSON?
        callback(err, adaptedBiz ) # immediately return the biz

        # see if yelp id is in session, if not, make a request
        @redisClient.hexists sessionId, yelpId, (err, alreadyExists)=>
          if 0 is alreadyExists
            console.log "#{yelpId} was not found in session"
            @redisClient.hmset sessionId, yelpId, ".", (err, ok)=># add the yelpId to this session
              console.log "#{yelpId} added to session"
              @redisClient.expire sessionId, YelpService.sessionTTL
            console.log "fetching #{yelpId} ..."
            YelpService.clientAPI.business yelpId, (err, yelpBiz)=>
              return if err?
              console.log "fetched #{yelpId} ..."
              adaptedBiz = (@_adaptBiz yelpBiz)
              bizJSON = (JSON.stringify adaptedBiz)
              @redisClient.set yelpId, bizJSON
              console.log "cache updated #{yelpId} ..."
              @redisClient.expire yelpId, YelpService.bizTTL
              console.log "refreshed expiration: #{yelpId}"
          else
            @redisClient.expire sessionId, YelpService.sessionTTL
            console.log "refreshed session"
      else 
        console.log "#{yelpId} not found in cache"
        console.log "fetching #{yelpId} ..."
        YelpService.clientAPI.business yelpId, (err, yelpBiz)=>
          if err?
            console.log "err fetching #{yelpId}"
            console.log err
            callback(err)
            return
          console.log "fetched #{yelpId} ..."
          console.log "returning #{yelpId} from fetch"
          adaptedBiz = (@_adaptBiz yelpBiz)
          callback(err, adaptedBiz)
          bizJSON = (JSON.stringify adaptedBiz)
          @redisClient.set yelpId, bizJSON
          console.log "cached #{yelpId} ..."
          @redisClient.expire yelpId, YelpService.bizTTL
          console.log "expiration set for #{yelpId}"

          @redisClient.hmset sessionId, yelpId, ".", (err, ok)=># add the yelpId to this session
            console.log "#{yelpId} added to session"
            @redisClient.expire sessionId, YelpService.sessionTTL
            console.log "expiration set for session"

  bizById:  (sessionId, yelpId, callback)=> (@biz sessionId, yelpId, callback)
  findById: (sessionId, yelpId, callback)=> (@biz sessionId, yelpId, callback)

  # need to create a socket version of this to return each biz 1 at a time (asynchrounously) as they are retrieved
  multiBiz: (sessionId, yelpIdList, callback)=>
    bizList = []
    for yelpId in yelpIdList
      do(yelpId) =>    
        @biz sessionId, yelpId, (err, biz)=>
          bizList.push biz || err
          if bizList.length is yelpIdList.length
            callback(null, bizList)
  multiBizByIds:  (sessionId, yelpIdList, callback)=> (@multiBiz sessionId, yelpIdList, callback)
  findByIds:  (sessionId, yelpIdList, callback)=> (@multiBiz sessionId, yelpIdList, callback)

  # Find biz by name does not cache the biz (always sends request to Yelp)
  bizByName: (name, location, callback) =>
    searchQuery = 
      term:     name
      location: location
      offset:   0
      limit:    1
    @_search(searchQuery, callback)
  findByName: (name, location, callback)=> (@bizByName name, location, callback)

  # search does not cache the biz (always sends request to Yelp)
  search: (term, location, page, callback)=>
    page = 1 if not page?  or page < 1# set page default to 1 if it is undefined or null
    if page?() and not callback? # set page default to 1 if it is not given at all
      callback = page
      page = 1

    searchQuery =
      term:     term
      location: location
      offset:   (page-1)* YelpService.resultsPerPage
      limit:    YelpService.resultsPerPage
    @_search(searchQuery, callback)

  _search: (searchQuery, callback)=>
    YelpService.clientAPI.search searchQuery, (err, searchResults)=>
      callback(err, (@_adaptSearchResults searchResults) )

  _adaptBiz: (biz)=>
    biz

  _adaptBizList: (bizList)=>
    bizList

  _adaptSearchResults: (searchResults)=>
    searchResults

module.exports = YelpService
