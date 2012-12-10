rorm_classKey = (className)->  "orm:" + className
rorm_key = (className, id)->  (rorm_classKey className) + ":" + id.toString()
rorm_keyForModel = (model)-> rorm_key model.className(), model.id()
rorm_wildcardKey= (className)-> (rorm_classKey className) + ':*'

BAD_KEY: new Error 'Bad Key!'
NO_MODEL_ID: new Error 'No Model ID!'
NO_MODEL_CLASS: new Error 'No Class found for model!'

###
#   ORM methods
#   ensure that these methods are not defined with => in order to bind to the calling subclass
###
RedisORM = 

  ###
  #   Instance methods
  #   eg:
  #   t = new Twitter(atts)
  #   t.save()
  #   t.destroy()
  ###
  extended: ->
    @include
      ###
      # save
      #   insert or update this object in the db: redis.set
      #   public instance method
      ###
      save: (callback)->
        try 
          redis.set rorm_keyForModel(@), @toJSON(), (err, ok)=>
            (callback err, ok) if callback?
        catch ex
          err = @rorm_logError ex
          (callback err) if callback?

      ###
      # destroy
      #   remove this object from the db: redis.del
      #   public instance method
      ###
      destroy: (callback)->
        try 
          redis.del rorm_keyForModel(@), (err, ok)->
            callback(null, false) if callback?
        catch ex
          rorm_logError ex
          (callback ex) if callback?

      ###
      # rorm_logError
      #   logs an exception, and returns an Error object
      #   private instance method
      ###
      rorm_logError: (exception)->
        console.log "exception:", exception.message, exception
        new Error exception.message


  ###
  #   materialize
  #   find an object from the db, or create a new one if one doesn't exists
  #   public class method
  ###
  materialize: (attributes, callback) ->
    @find attributes, (err, obj)=>
      return (callback err) if err?
      o = obj
      unless o?
        clazz = @rorm_modelClass()
        try
          o = new clazz(attributes)
        catch ex
          err = @rorm_logError "Can not materialize #{@rorm_modelClassName()} from #{attributes}"
      callback null, o

  ###
  # find
  #   public class method
  ###
  modelIDFor: (id)-> id

  find: (model, callback )->
    key = rorm_keyForModel(model) if 'function' is typeof model.className and 'function' is typeof model.id
    unless key?
      className = @rorm_modelClassName()
      id = if model.isHash() then model.id else model.toString()
      id = @modelIDFor(id)
      key = rorm_key(className, id)
    callback(BAD_KEY) unless key?
    @rorm_findObjectForKey key, callback

  ###
  # findById
  #   public class method
  ###
  findById: (id, callback )->
    ( return callback(@NO_MODEL_ID, null) )unless id? # check that args are given
    className = @rorm_modelClassName()      
    key = rorm_key(className, @modelIDFor(id))
    @rorm_findObjectForKey key, callback

  ###
  # findAll
  #   public class method
  ###
  findAll: (callback)->
    wildcard = (rorm_wildcardKey @rorm_modelClassName())
    redis.keys wildcard, (err, keyNames) =>
      return callback(err) if err?
      return callback(null, []) unless keyNames?.length > 0
      models = []
      for key, idx in keyNames
        do(key, idx)=>
          @rorm_findObjectForKey key, (err, model)=>
            models.push model
            callback(null, models) if models.length is keyNames.length

  ###
  #   Class information
  ###
  rorm_modelClassName: ()-> @::['constructor'].name
  rorm_modelClass: ()-> 
    clazz = global[@rorm_modelClassName()]
    throw @NO_MODEL_CLASS unless clazz
    clazz    

  # private utils
  rorm_clazz: (key)->
    className = @rorm_classNameForKey key
    throw "Class not found [#{className}] from key '#{key}'" unless global[className]?
    global[className]

  rorm_classNameForKey: (key)->
    throw "Can not find class name for null key" unless key?
    keyTokens = key.split(':')
    throw "No class name in key '#{key}'" unless 1 < keyTokens.length
    clazzName = keyTokens[1]

  rorm_findObjectForKey: (key, callback )->
    redis.get key, (err, json_string)=>
      result = null;
      try 
        result = @rorm_objectFromJSON(@rorm_clazz(key), json_string)
      catch ex
        err = @rorm_logError ex
      finally
        (callback err, result)

  rorm_findArrayForKey: (key, callback)->
    redis.get key, (err, json_string)=>
      result = null;
      try 
        result = JSON.parse(json_string)
      catch ex
        err = @rorm_logError ex
      finally
        list = result.list || []
        (callback err, list) if callback?()

  rorm_saveArrayForKey: (key, list, callback)->
    return false unless key? and list?
    ok = false
    try 
      obj = { list: list }
      redis.set key, (JSON.stringify obj) # save tweet by tweet id
      ok = true
    catch ex
      err = @rorm_logError ex
      ok = false
    finally
      (callback err, ok) if callback?()

  rorm_objectFromJSON: (clazz, json_string)->
    return null unless json_string
    new clazz JSON.parse(json_string)

  rorm_logError: (exception)->
    console.log "exception:", (exception.message||''), exception
    new Error(exception.message || exception)

module.exports = RedisORM
