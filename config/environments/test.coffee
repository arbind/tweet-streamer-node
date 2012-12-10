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
rootPath.factories = (rootPath.spec + 'factories/')

# framework:test
global.chai = (require 'chai')
global.Charlatan = (require 'charlatan')
chai.use (require 'chai-factories')

global.should = chai.should()
global.expect = chai.expect
global.assert = chai.assert

global.fixtureFor = (name)-> (require rootPath.fixtures + name)

global.clearRedisTestEnv = (msg, callback)->
  if redisTestDB is redis.selected_db
    redis.dbsize (err, size)->
      console.log "redis[#{redis.selected_db}]:", msg, "purging #{size} keys" if 0 < size
      redis.flushdb (err, ok) ->
        callback(null, ok)
  else
    p redisTestDB
    callback(new Error "redis selected db ##{dbNum} - Test Environment is db ##{redisTestDB}" ) 

global.ensureClearRedisTestEnvironment = (msg, callback)->
  if redisTestDB is redis.selected_db 
    clearRedisTestEnv msg, callback
  else
    redis.on 'db-select', (dbNum)=> clearRedisTestEnv msg, callback

