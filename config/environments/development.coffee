global.env = 'development'
global.debug = true
# DB:redis
global.redisURL = 'redis://127.0.0.1:6379'
global.redisDBNumber = redisDevelopmentDB

global.mongoURL = 'localhost:27017/yelp_service_dev'

# twitter oauth secrets
global.TwitterConsumers =
  streamersApp:
    key: 'ys0BKjMp79ZW6udBeCnGbg'
    secret: 'krLI6aRtS19lFglUkn87qUc2vyNWVk1N4df2ENzsTE'
    callback_url: 'http://www.food-truck.ws/streamers/authorize/callback'
