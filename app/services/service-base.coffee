class ServiceBase extends EventEmitter

  # finders
  @_findObjectForKey: (clazz, key, callback )=>
    redis.get key, (err, json_string)=>
      result = null;
      try 
        result = @_objectFromJSON(clazz, json_string)
      catch ex
        err = @logError '#{className}Service @_findObjectForKey: \n', ex
        console.log 'err: #{key}'
        console.log err
      finally
        (callback err, result)

  @_findArrayForKey: (key, callback)->
    redis.get key, (err, json_string)=>
      result = null;
      try 
        result = JSON.parse(json_string)
      catch ex
        err = @logError 'ServiceBase @_findArrayForKey: \n', ex
        console.log 'err: #{key}'
        console.log err
      finally
        list = result.list || []
        (callback err, list) if callback?()

  @_saveArrayForKey: (key, list, callback)->
    return false unless key? and list?
    ok = false
    try 
      obj = { list: list }
      redis.set key, (JSON.stringify obj) # save tweet by tweet id
      ok = true
    catch exception
      console.log "exception #{exception} ."
      logError exception
      ok = false
    finally
      (callback err, ok) if callback?()

  # de-serialization
  @_objectFromJSON: (clazz, json_string)=> # throws exception if json can not be parsed
    return null unless json_string
    new clazz JSON.parse(json_string)

  @_streamerFromJSONArray: (clazz, jsonArray)=>
    resultList = []
    return resultList unless jsonArray
    for json_string in jsonArray
      obj = (@_objectFromJSON clazz, json_string) if json_string?
      resultList.push obj if obj?
    resultList

module.exports = ServiceBase