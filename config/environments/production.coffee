global.env = 'production'
global.debug = false

# DB:redis
global.redisURL = process.env.REDISTOGO_URL
global.redisDBNumber = redisProductionDB

# DB:mongo
global.mongoURL = process.env.MONGOLAB_URI

# twitter oauth secrets
global.TwitterConsumers =
  streamersApp:
    key: 'ys0BKjMp79ZW6udBeCnGbg'
    secret: 'krLI6aRtS19lFglUkn87qUc2vyNWVk1N4df2ENzsTE'
    callback_url: 'http://www.food-truck.ws/streamers/authorize/callback'
