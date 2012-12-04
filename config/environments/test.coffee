global.env = 'test'
global.debug = true

# DB:redis
global.redisURL = 'redis://127.0.0.1:6379'
global.redisDBNumber = redisTestDB

# DB:mongo
global.mongoURL = 'localhost:27017/yelp_service_test'

# twitter oauth secrets
global.TwitterConsumers =
  streamersApp:
    key: 'ys0BKjMp79ZW6udBeCnGbg'
    secret: 'krLI6aRtS19lFglUkn87qUc2vyNWVk1N4df2ENzsTE'
    callback_url: 'http://www.food-truck.ws/streamers/authorize/callback'

# additional application paths in test environment
rootPath.spec = (rootPath.path + 'spec/')
rootPath.fixtures = (rootPath.spec + 'fixtures/')

# framework:test
global.chai = (require 'chai')
global.should = chai.should()
global.expect = chai.expect
global.assert = chai.assert

global.fixtureFor = (name)-> (require rootPath.fixtures + name)

global.ensureTestEnvironment = (callback)->
  if redisTestDB is redis.selectedDB 
    callback() 
  else
    redis.on 'db-select', (dbNum)=>
      if redisTestDB is redis.selectedDB 
        callback() 
      else
        p redisTestDB
        callback(new Error "redis selected db ##{dbNum} - Test Environment is db ##{redisTestDB}" ) 