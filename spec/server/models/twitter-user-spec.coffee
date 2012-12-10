describe 'TwitterUser', ->
  # This is a spec for:
  @subjectClass = TwitterUser

  ###
  #   instance variables shared by specs
  ###
  @atts = null
  @savedAtts = null
  @subject = null
  @savedSubject = null

  before (done)=> ensureClearRedisTestEnvironment("before TwitterUser specs:", done)
  after (done)=> ensureClearRedisTestEnvironment("after TwitterUser specs:", done)

  it 'exists', (done)=> 
    (expect @subjectClass).to.exist
    done()

  it 'database is empty', (done)=>
    @subjectClass.findAll (err, list)=>
      (expect err).not.to.exist
      (expect list).to.exist
      (expect list).to.be.empty
      done()

  it 'save', (done)=>
    atts = @subjectClass::TESTDATA.make()
    tu = new @subjectClass(atts)
    count = 0
    @subjectClass.findAll (err, listBefore)=>
      count = listBefore.length if isPresent(listBefore)
      tu.save (err, ok)=>
        @savedSubject = tu
        @subjectClass.findAll (err, listAfter)=>
          (expect listAfter).to.exist
          (expect listAfter.length).to.equal count+1
          done()

  it 'find', (done)=>
    @subjectClass.find @savedSubject.id(), (err, obj)->
      (expect err).not.to.exist
      (expect obj).to.exist
      (expect obj.screenName()).to.equal @savedSubject.screenName()
      done()

  it 'destroy', (done)=>
    count = 9999
    @subjectClass.findAll (err, listBefore)->
      count = listBefore.length if isPresent(listBefore)
      @savedSubject.destroy()
      @savedSubject = null
      @subjectClass.findAll (err, listAfter)->
        (expect listAfter).to.exist
        (expect listAfter.length).to.equal count-1
        done()

  it 'findAll', (done) =>
    count = 0
    @subjectClass.findAll (err, listBefore)->
      count = listBefore.length if isPresent(listBefore)
      more = 8
      addMore = more
      newStreamers = []
      while addMore--
        h = @subjectClass::TESTDATA.make()
        s = new @subjectClass(h)
        s.save()
        newStreamers.push s
      @subjectClass.findAll (err, listAfter)->
        (expect listAfter).to.exist
        (expect listAfter.length).to.equal count + more
        s.destroy() for s in newStreamers # clear the newly created streamers
        done()

  describe 'materialize', ->
    before (done) =>
      @atts = @subjectClass::TESTDATA.make()
      done()

    describe 'new', ->
      @subject = null
      before (done) => 
        uidString = "00#{@uid}"
        @subjectClass.materialize @atts, (err, obj)->
          (expect err).to.be.null
          (expect obj).to.be.ok
          @subject = obj
          done()

      it 'instance has relevant attributes', (done) =>
        (expect @subject.id()).to.equal @atts.id
        (expect @subject.screenName()).to.equal @atts.screen_name
        (expect @subject.profileImageURL()).to.equal @atts.profile_image_url
        done()


      it '.toJSON has relevant attributes', (done) =>
        jsonValue = @subject.toJSON()
        jsonValue.should.be.a('string')
        jsonSubject = JSON.parse(jsonValue)
        jsonSubject.should.be.an('object')
        (expect jsonSubject.contains @atts).to.be.true # streamer contains all the original atts
        done()

      it '.toEvent has relevant attributes', (done) =>
        ev = @subject.toEvent()
        (expect ev.contains @atts).to.be.true # streamer contains all the original atts
        (expect @atts.contains ev).to.be.true # streamer contains more than the original atts
        done()


      it.skip '.emit to socket sends only attributes'
      it.skip '.emit to EventMachine sends the instance obj'

    describe 'existing', ->

      before (done) => 
        @savedAtts = @subjectClass::TESTDATA.make()
        @savedSubject = new @subjectClass(@savedAtts)
        @savedSubject.save done

      after (done) => 
        @savedSubject.destroy done

      it 'from db with string id ', (done)=>
        idString = "00#{@savedAtts.id}"
        @subjectClass.materialize idString, (err, obj)->
          (expect err).to.be.falsy
          (expect obj).to.be.ok
          (expect obj.id()).to.equal @savedAtts.id
          (expect obj.screenName()).to.equal @savedAtts.screen_name
          (expect obj.profileImageURL()).to.equal @savedAtts.profile_image_url
          done()

      it 'from db with numeric id ', (done)=>
        idNumber = parseInt @savedAtts.id, 10
        @subjectClass.materialize idNumber, (err, obj)->
          (expect err).to.be.falsy
          (expect obj).to.be.ok
          (expect obj.id()).to.equal @savedAtts.id
          (expect obj.screenName()).to.equal @savedAtts.screen_name
          (expect obj.profileImageURL()).to.equal @savedAtts.profile_image_url
          done()  