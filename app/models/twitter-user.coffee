class TwitterUser extends ModelBase
  Service: TweetService

  constructor: (atts) ->
    super()
    fields = [ 'id', 'name', 'screen_name', 'profile_image_url', 'location', 'lang' ] 
    @setFields atts, fields

  className: ()-> 'TwitterUser'
  screenName: ()-> (@user().screen_name)

module.exports = Tweet
