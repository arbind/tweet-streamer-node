OAuth= require('oauth').OAuth
consumer:
  key: 'ys0BKjMp79ZW6udBeCnGbg'
  secret: 'krLI6aRtS19lFglUkn87qUc2vyNWVk1N4df2ENzsTE'
  callback_url: 'http://www.food-truck.ws/oauth/twitter/foodtruckws/callback'

oa = new OAuth "https://api.twitter.com/oauth/request_token", "https://api.twitter.com/oauth/access_token", consumer.key, consumer.secret, "1.0", consumer.callback_url, "HMAC-SHA1"

exports.login = (req, res) ->
  oa.getOAuthRequestToken (error, oauth_token, oauth_token_secret, results) ->
    if error
      console.log(error)
      res.send("yeah no. didn't work.")
    else
      req.session.oauth = {}
      req.session.oauth.token = oauth_token
      req.session.oauth.token_secret = oauth_token_secret
      res.redirect('https://twitter.com/oauth/authenticate?oauth_token='+oauth_token)

exports.login_callback = (req, res) ->
  if req.session.oauth
    oauth = req.session.oauth
    req.session.oauth.verifier = req.query.oauth_verifier
    oa.getOAuthAccessToken oauth.token, oauth.token_secret, oauth.verifier, (error, oauth_access_token, oauth_access_token_secret, results) ->
      if error
        console.log error
        res.redirect('/')
      else
        req.session.oauth = {}
        twitter_id = results.user_id
        screen_name = results.screen_name
        update_access_token(twitter_id, screen_name, oauth_access_token, oauth_access_token_secret)
        res.redirect('/streamers')
  else
    res.redirect('/')
