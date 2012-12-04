class Tweet extends ModelBase
  Service: TweetService
  className: ()-> 'Tweet'

  text: ()-> (@get 'text')

  user: ()-> (@get 'user') || {}
  screenName: ()-> (@user().screen_name)

  streamer: ()-> (@get 'streamer') || {}
  streamerScreenName: ()-> (@streamer().screen_name)

module.exports = Tweet
