# describe 'Tweet', ->
#   before (done) ->
#     done()

#   describe.skip '@@constructor', ->
#     before (done) ->
#       done()

#     it 'exists', (done) =>
#       @la = 'la';
#       @laStreamer = new Streamer {id: 1, screen_name:la}
#       @tweet1 = new Tweet {id:11, text: "first tweet", user:{id: 111, screen_name:'grill', id:'grill-1'} }
#       @tweet1.setStreamer(laStreamer)

#       @sf = 'sf'
#       @sfStreamer = new Streamer {id: 2, screen_name:sf}
#       @tweet2 = new Tweet {id:22, text: "second tweet", user:{id: 222, screen_name:'bbq', id:'bbq-1'} }
#       @tweet1.setStreamer(sfStreamer)


#     it '(constructor attributes)', (done) =>
#       @tweet1.exists
#       @tweet2.exists
#       @tweet1.id().should.not.equal @tweet2.id()
#       done()

#   describe.skip 'rest', ->
#     it '.screenName', (done) =>
#       @tweet1.user().screenName().should.equal 'grill'
#       @tweet2.user().screenName().should.equal 'bbq'
#       done()

#     it '.streamer().screenName', (done) =>
#       @tweet1.streamer().screenName().should.equal @la
#       @tweet2.streamer().screenName().should.equal @sf
#       done()

#     it '.toJSON', (done) =>
#       jsonValue = '{"streamer":"la","id":1,"text":"first tweet"}' # Exactly formated
#       json = JSON.parse jsonValue
#       @tweet1 = new Tweet json
#       @tweet1.toJSON().should.equal jsonValue                     # Matches Exact format
#       done()
