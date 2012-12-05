global.isPresent = (obj)->
  return false unless obj?
  return true for own key, val of obj # hasOwnProperty of any key?
  return false

global.isEmpty = (obj)-> not isPresent(obj)

unless Object.keys?
  Object.keys = (obj)->
    return [] if obj is null or obj is undefined or obj isnt Object(obj)
    key for own key, val of obj

unless global.merge?
  global.merge = (targetHash, hashList...)->
    for hash in hashList
      targetHash[key] = val for own key, val of hash
    targetHash
