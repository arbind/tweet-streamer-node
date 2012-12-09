class Tweet extends ModelBase
  Service: TweetService
  classFieldNames:  [ 'id'
                    , 'text'
                    , 'created_at'
                    , 'in_reply_to_status_id'
                    , 'in_reply_to_user_id'
                    , 'in_reply_to_screen_name'
                    , 'geo'
                    , 'coordinates'
                    , 'place'
                    , 'retweet_count'
                    , 'retweeted'
                    ]

  constructor: (attributes) ->
    super(attributes)
    return unless atts? and isPresent(atts)
    @set 'urls', attributes.entities.urls if attributes.entities?.urls?

    if attributes.user? # save/update the user
      u = new TwitterUser attributes.user
      @setUser u

  text: ()-> (@get 'text')

  user: ()-> @getRef 'user'
  setUser: (user)->  @setRef 'user', user

  streamer: ()-> @getRef 'streamer'
  setStreamer: (streamer) -> @setRef 'streamer', streamer

module.exports = Tweet

###
#
###