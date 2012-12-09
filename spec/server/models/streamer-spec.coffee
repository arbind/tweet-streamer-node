describe 'Streamer', ->

  before (done)=> ensureClearRedisTestEnvironment("before:", done)
  # after (done)=> ensureClearRedisTestEnvironment("after:", done)

  it 'exists', (done)=> 
    (expect Streamer).to.exist
    done()

  it 'empty database', (done)->
    Streamer.findAll (err, list)->
      (expect err).not.to.exist
      (expect list).to.exist
      (expect list).to.be.empty
      done()

  describe 'materialize', ->
    @atts = 
      id: 11
      name: 'FTAUSTXUSA'
      screen_name: 'my_user_name'
      description: 'food truck streamer'
      location: 'Austin, TX'
      lang: 'en'
      followers_count: 5
      friends_count: 444
      time_zone: 'Central Time (US & Canada)'
      utc_offset: -21600

    @consumerApp = 'streamersApp'
    @consumer = TwitterConsumers[@consumerApp]

    @token= 'abc'
    @secret='hidden'
    @streamer = null

    before (done) => 
      (expect @consumer).to.be.ok
      done()

    describe 'new', ->
      before (done) => 
        uidString = "00#{@uid}"
        Streamer.materialize @atts, @consumerApp, @token, @secret, (err, streamer)->
          (expect err).to.be.null
          (expect streamer).to.be.ok
          @streamer = streamer
          done()

      it 'has an integer id and relevant attributes', (done) =>
        @streamer.id().should.equal @atts.id
        @streamer.screenName().should.equal @atts.screen_name
        @streamer.description().should.equal @atts.description
        @streamer.location().should.equal @atts.location
        @streamer.language().should.equal @atts.lang
        @streamer.followersCount().should.equal @atts.followers_count
        @streamer.friendsCount().should.equal @atts.friends_count
        @streamer.timeZone().should.equal @atts.time_zone
        @streamer.utcOffset().should.equal @atts.utc_offset
        done()

      it 'has oauth credentials including consumer app and access token', (done) =>
        oauth = @streamer.oauthAccess()
        (expect oauth).to.exist
        (expect oauth.consumer_key).to.equal @consumer.key
        (expect oauth.consumer_secret).to.equal @consumer.secret
        (expect oauth.access_token_key).to.equal @token
        (expect oauth.access_token_secret).to.equal @secret
        done()

      it '.toJSON', (done) =>
        jsonValue = @streamer.toJSON()
        jsonValue.should.be.a('string')
        jsonStreamer = JSON.parse(jsonValue)
        jsonStreamer.should.be.an('object')
        (expect jsonStreamer.contains @atts).to.be.true # streamer contains all the original atts
        (expect @atts.contains jsonStreamer).to.be.false # streamer contains more than the original atts
        done()

      it '.toJSON shows oauth_access', (done)=>
        jsonValue = @streamer.toJSON()
        jsonStreamer = JSON.parse(jsonValue)
        oauth = jsonStreamer.oauth_access
        (expect oauth).to.exist
        (expect oauth.token)
        (expect oauth.app).to.equal @consumerApp
        (expect oauth.token).to.equal @token
        (expect oauth.secret).to.equal @secret
        done()

      it '.toEvent has relevant attributes', (done) =>
        ev = @streamer.toEvent()
        (expect ev.contains @atts).to.be.true # streamer contains all the original atts
        (expect @atts.contains ev).to.be.true # streamer contains more than the original atts
        done()

      it '.toEvent hides oauth_access', (done)=>
        ev = @streamer.toEvent()
        (expect ev.oauth_access).not.to.exist
        done()

      it.skip '.emit to socket sends only attributes'
      it.skip '.emit to EventMachine sends the instance obj'

      it 'save', (done)=>
        count = 0
        Streamer.findAll (err, listBefore)->
          count = listBefore.length if isPresent(listBefore)
          @streamer.save()
          Streamer.findAll (err, listAfter)->
            (expect listAfter).to.exist
            (expect listAfter.length).to.equal count+1
            done()

    describe 'existing', ->
      @savedStreamer = null
      before (done) => 
        Streamer.materialize @atts.id, @consumerApp, @token, @secret, (err, streamer)->
          (expect err).to.be.null
          (expect streamer).to.be.ok
          (expect streamer.screenName()).to.equal @atts.screen_name
          @savedStreamer = streamer
          done()
      after (done) => 
        @savedStreamer.destroy()
        done()

      it 'has all attributes', (done)=>
        @savedStreamer.id().should.equal @atts.id
        @savedStreamer.screenName().should.equal @atts.screen_name
        @savedStreamer.description().should.equal @atts.description
        @savedStreamer.location().should.equal @atts.location
        @savedStreamer.language().should.equal @atts.lang
        @savedStreamer.followersCount().should.equal @atts.followers_count
        @savedStreamer.friendsCount().should.equal @atts.friends_count
        @savedStreamer.timeZone().should.equal @atts.time_zone
        @savedStreamer.utcOffset().should.equal @atts.utc_offset
        done()

      it 'find', (done)=>
        Streamer.find @savedStreamer.id(), (err, obj)->
          (expect err).not.to.exist
          (expect obj).to.exist
          (expect obj.screenName()).to.equal @savedStreamer.screenName()
          (expect obj.oauthAccess().access_token_secret).to.equal @secret
          done()

      it 'findAll', (done) =>
        count = 0
        Streamer.findAll (err, listBefore)->
          count = listBefore.length if isPresent(listBefore)
          more = 8
          addMore = more
          newStreamers = []
          while addMore--
            h = StreamerFactory.make()
            s = new Streamer h
            s.save()
            newStreamers.push s
          Streamer.findAll (err, listAfter)->
            (expect listAfter).to.exist
            (expect listAfter.length).to.equal count + more
            s.destroy() for s in newStreamers # clear the newly created streamers
            done()

      it 'destroy', (done)=>
        count = 9999
        Streamer.findAll (err, listBefore)->
          count = listBefore.length if isPresent(listBefore)
          @savedStreamer.destroy()
          Streamer.findAll (err, listAfter)->
            (expect listAfter).to.exist
            (expect listAfter.length).to.equal count-1
            done()

  describe.skip 'twitter API', (done) ->

    it 'fetchUser', (done) =>
    it 'fetchFriends', (done) =>
    it 'fetchHomeTimeline', (done) =>
    it 'fetchNewTweets', (done) =>
    it 'pull', (done) =>

  describe.skip 'streaming', (done) ->
    it 'saveTweets', (done) =>    
    it 'startStreaming', (done) =>    
    it 'stopStreaming', (done) =>
