# load routes
routes = {}
routes.auth = (require './auth')
routes.homepage = (require './homepage')
routes.streamers = (require './streamers')

# userRoutes = (require './user')
# yelpRoutes = (require './yelp')

# set appData javascript variable for all responses (using express-expose)
app.all '*', (req, res, next) -> 
  res.expose({}, 'appData'); next()
  # res.expose ()->
  #   notify = ()-> alert('this will execute right away :D')
  #   notify()

# pre-processor: capture route params and move into req.query
app.param 'sessionId', (req, res, next, sessionId) -> req.query.sessionId = sessionId; next()

# Define the Application's Routes

# homepage
app.get [ '/', '/index' ], routes.homepage.index

# auth
app.get '/login', routes.auth.login
app.get '/logout', routes.auth.logout

# streamers
app.get '/streamers',                     routes.streamers.index
app.get '/streamers/authorize',           routes.streamers.twitterOAuth
app.get '/streamers/authorize/callback',  routes.streamers.twitterCallback

# exports.oauth_twitter   = (require './oauth_twitter')
# exports.tweet_streamers = (require './tweet_streamers')
