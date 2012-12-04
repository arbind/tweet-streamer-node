OAuth = require('oauth').OAuth
twitterConsumer = TwitterConsumers.streamersApp

oa = new OAuth "https://api.twitter.com/oauth/request_token", "https://api.twitter.com/oauth/access_token", twitterConsumer.key, twitterConsumer.secret, "1.0", twitterConsumer.callback_url, "HMAC-SHA1"

exports.index = (req, res) ->
  Streamer.findAll (err, streamers)->
    res.render "streamers", title: 'Tweet Streamers', streamers: streamers, req: req, res: res

exports.twitterOAuth = (req, res) ->
  oa.getOAuthRequestToken (error, oauth_token, oauth_token_secret, results) ->
    res.redirect('/') if error
    req.session.oauth = 
      token: oauth_token
      token_secret: oauth_token_secret
    res.redirect('https://twitter.com/oauth/authenticate?oauth_token='+oauth_token)

exports.twitterCallback = (req, res) ->
  return res.redirect('/') unless req.session.oauth?

  oauth = req.session.oauth
  delete req.session['oauth']

  oauth.verifier = req.query.oauth_verifier
  oa.getOAuthAccessToken oauth.token, oauth.token_secret, oauth.verifier, (error, oauth_access_token, oauth_access_token_secret, twitter_info) ->
    return res.redirect('/') if error?
    oauthAccess = 
      app: 'streamersApp'
      token: oauth_access_token
      secret: oauth_access_token_secret
    Streamer.materialize twitter_info.user_id, twitter_info.screen_name, oauthAccess, (err, streamer)->
      streamer.save()
      streamer.pull()
      streamer.startStreaming()

    # TweetStreamService.saveStreamerAccount(twitter_info, oauth_access_token, oauth_access_token_secret)
    res.redirect('/streamers')
