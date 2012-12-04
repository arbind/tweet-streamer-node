global.isPresent = (obj)->
  return true for own key, val of obj # hasOwnProperty of any key?
  return false

global.isEmpty = (obj)-> not isPresent(obj)

unless Object.keys?
  Object.keys = (obj)->
    throw new TypeError('Object.keys called on non-object') if obj isnt Object(obj)
    key for own key, val of obj
