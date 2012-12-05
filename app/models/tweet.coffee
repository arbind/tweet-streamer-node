class Tweet extends ModelBase
  Service: TweetService
  user: null
  streamer: null

  constructor: (atts) ->
    super()
    fields = ['id', 'text', 'created_at', 'in_reply_to_status_id', 'in_reply_to_user_id', 'in_reply_to_screen_name', 'geo', 'coordinates', 'place', 'retweet_count', 'retweeted' ]
    @setFields atts, fields 
    @set 'urls', atts.entities.urls if atts.entities?.urls?

    if atts.user # save/update the user
      u = new TwitterUser atts.user
      console.log 'new user data'
      console.log atts.user
      console.log 'new user object'
      console.log u
      console.log 'new user id'
      console.log u.id()
      @setUser u

  text: ()-> (@get 'text')
  screenName: ()-> (@user().screen_name)

  user: ()-> @getRef 'user'
  setUser: (user)->  @setRef 'user', user

  streamer: ()-> @getRef 'streamer'
  setStreamer: (streamer) -> @setRef 'streamer', streamer

module.exports = Tweet

###
#
###