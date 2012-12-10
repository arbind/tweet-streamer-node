# configure an express app: code structure and environment (test, development, production)

global.node_env = process.env.NODE_ENV || global.localEnvironment || 'test'
console.log "***********************"
console.log "#{node_env} environment"
console.log "-----------------------"

path          = (require 'path')
express       = (require 'express')
expose        = (require 'express-expose')
connectAssets = (require 'connect-assets')
RedisStore    = (require 'connect-redis')(express)

# export the app, and make it available globally
app = express()
global.app = app
module.exports = app

rootDir = (path.normalize __dirname + '/..')

assetsPipeline = connectAssets src: 'app/assets'
css.root = 'stylesheets'
js.root = 'javascripts'

secret = process.env.CLIENT_SECRET || 'h2o'
app.configure ->
  app.set 'port', process.env.PORT || process.env.VMC_APP_PORT || 8888
  app.set 'views', (rootDir + '/app/views')
  app.set 'view engine', 'jade'
  app.use express.favicon()
  app.use express.logger('dev')
  app.use express.methodOverride()
  app.use assetsPipeline
  app.use express.bodyParser()

app.configure 'production', ->
  app.use express.errorHandler()
app.configure 'development', ->
  app.use (express.errorHandler dumpExceptions: true, showStack: true )

global.FS = (require 'fs')

# application paths
global.rootPath = {}
rootDir = process.cwd()
rootPath.path =       (rootDir + '/')
rootPath.db =         (rootPath.path + 'db/')
rootPath.config =     (rootPath.path + 'config/')
rootPath.public =     (rootPath.path + 'public/')

rootPath.app =        (rootPath.path + 'app/')
rootPath.utils =      (rootPath.app + 'utils/')
rootPath.assets =     (rootPath.app + 'assets/')
rootPath.models =     (rootPath.app + 'models/')
rootPath.routes =     (rootPath.app + 'routes/')
rootPath.services =   (rootPath.app + 'services/')
rootPath.extentions = (rootPath.app + 'extentions/')

global.requireModuleInFile = (path, filename)->
  filePath = path+filename
  try
    if String.prototype.toClassName
      className = filename.toClassName()
      throw "Class name #{className} already exists! Rename file '#{filename}' " if global[className]?
      clazz = require filePath    # if anything is exported, assume that it is a Class
      global[className] = clazz   # make the class available globally
    else
      require filePath
  catch exception
    console.log ""
    console.log "!! could not load #{filename} from #{path}"
    throw exception

global.requireModulesInDirectory = (path)->
  (requireModuleInFile path, f) for f in FS.readdirSync(path)

# load some usefull stuff
requireModulesInDirectory rootPath.extentions
requireModulesInDirectory rootPath.utils
# global.Util = (require rootPath.utils + 'util')
# global.puts = (require rootPath.utils + 'puts')
# global.log  = (require rootPath.utils + 'log')

# set application configurations
global.redisURL = null # runtime environment would override this, if using redis
global.redisDBNumber = 99999 # runtime environment would also override this to one of the DB numbers below:
global.redisTestDB = 2
global.redisDevelopmentDB = 1
global.redisProductionDB = 0

global.mongoURL = null

# load runtime environment
require "./environments/#{node_env}"

# connect to mondoDB
if mongoURL
  global.mongoDB = (require 'mongoskin').db mongoURL
  # +++ create database if it does not exists?

# connect to redis
if redisURL
  redis = require('redis-url').connect(redisURL)
  global.redis = redis
  redis.on 'connect', =>
    redis.send_anyways = true
    # console.log "\nredis[0]: connection established"
    redis.select redisDBNumber, (err, val) => 
      redis.send_anyways = false
      redis.selected_db = redisDBNumber
      console.log "redis[#{redis.selected_db}]: selected DB ##{redisDBNumber} for #{env} environment"
      redis.dbsize (err, size)=>
        console.log "redis[#{redis.selected_db}]: selected DB has #{size} keys" if 0 < size
        redis.emit 'db-select', redisDBNumber

sessionStore = if redis? then new RedisStore {client: redis} else new express.session.MemoryStore;

app.configure -> 
  app.use express.cookieParser(secret)
  app.use express.session(secret: secret, store: sessionStore)
  maxAge : new Date Date.now() + 7200000 # 2h Session lifetime

# routes paths should override paths to static files
# session needs to be setup before routes are setup
app.configure -> 
  app.use app.router
  app.use express.static(path.join(rootDir, 'public'))

# load deps
{ EventEmitter }  = (require 'events')
Twitter        = (require 'ntwitter')
global.Twitter = Twitter
global.EventEmitter = EventEmitter

# load classes
require rootPath.services
require rootPath.models

# Load app routes
require rootPath.routes

