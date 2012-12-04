# https://gist.github.com/1805743
class App
  express = require 'express'
  redis = require 'redis'
  RedisStore = require('connect-redis')(express)
  sessionStore = new RedisStore()
  
  # These will be used only on ioController()
  fs = require 'fs'
  parseCookie = require('connect').utils.parseCookie

  constructor:->
    @initAndConfigureApp()
    @runApp()
    @ioController()

  initAndConfigureApp:->
    @app = module.exports = express.createServer()

    @app.configure () =>
      @app.use express.bodyParser()
      @app.use express.cookieParser()
      @app.use express.session
        secret: "any random thing that cross your mind"
        store: sessionStore

  runApp:->
    @app.listen 3000, =>
      console.info "Express server listening on port #{@app.address().port} in #{@app.settings.env} mode"

  ioController:->
    @io = require('socket.io').listen @app

    @io.configure () =>
      # This is the important part, reading the sessionStore
      @io.set 'authorization', (data, callback) =>
        if data.headers.cookie?
          data.cookie = parseCookie data.headers.cookie
          sessID = data.cookie['connect.sid'] # This could change, if you change the value while configuring the express server with the `key` param in express.session. is connect.sid by default in connect and express
          sessionStore.get sessID, (err, session) =>
            if err or not session
              callback new Error "There's no session"
            else
              callback null, true
              # Here's where you can read session info and know if the user is authenticated, or any kind of info you saved about your visitor on the cookie. So if you want to check req.session.user you just call session.user here, and so on.
        else
          callback new Error "No cookie transmitted!"

    @io.on 'connection', (socket) =>
      console.info "Got connected to server!"

# Start the class!!
app = new App()