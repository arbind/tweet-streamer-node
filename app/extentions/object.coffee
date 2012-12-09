global.isPresent = (obj)->
  return false unless obj?
  return true for own key, val of obj # hasOwnProperty of any key?
  return false

global.isEmpty = (obj)-> not isPresent(obj)


global.isString = (thing)-> 'string' is typeof thing or thing instanceof String
global.isNumber = (thing)-> 'number' is typeof thing or thing instanceof Number

Object::keys ||= ()-> key for own key, val of @

Object::isHash ||= ()->
  ok = true
  ok = false unless Object is @constructor
  ok = false unless 'string' is typeof @[key] for own key, val of @
  ok

Object::contains ||= (obj)->
  return false unless obj? and obj.isHash()
  ok = true
  ok &&= @[key] is obj[key] for own key of obj
  ok

Object::inject ||= (hashList...)->
  for hash in hashList
    @[key] = val for own key, val of hash
  @

Object.merge ||= (targetHash, hashList...)->
  for hash in hashList
    targetHash[key] = val for own key, val of hash
  targetHash
