class ModelBase
  _attributes: null
  _refs: null

  constructor: (attributes) -> 
    @_attributes = attributes || {}
    @_refs = {}
    @loadRefs()

  className: ()-> @constructor.name

  id: ()-> @get('id')

  get: (attName) -> @_attributes[attName] || null
  set: (attName, value) -> 
    return unless attName
    @_attributes[attName] = value

  setRef: (name, obj)->
    @_attributes._refIds ||= {}
    @_attributes._refIds[name] = obj.id()
    @_refs[name] = obj

  getRef: (name)->
    return @_refs[name] if @_refs[name]?        # return the object if it is already loaded
    return null unless @_attributes._refIds[name]?          # return null if there is no object or refId for this name
    @_refs[name] = @loadRef(name, @_attributes._refIds[name]) # load the actual object if there is a refId

  loadRefs: ()=> # recursively load all refs
    return unless @_attributes._refIds # nothing to load if there are no refIds
    return if Object.keys(@_attributes._refIds).length is Object.keys(@_refs).length  # return if refs are already loaded
    nextRef = null # find the next ref that needs to be loaded:
    (nextRef ||= refName unless @_refs[refName]?) for refName, refId in @_attributes._refIds
    @loadRef name, @_attributes._refIds[name], (err, obj) =>
      @_refs[name] = obj || null
      @loadRefs() # recursively load all refs

  loadRef: (name, id, callback)->
    svcClassName = name.toTitleCase()+"Service"
    svcClass = global[svcClassName]  
    svcClass.find id, callback

  # set a subset of atts
  setFields: (atts, fieldNames) => (@set field, atts[field] if atts[field]?) for field in fieldNames if atts?

  # subclasses can define an @service attribute in order to implement these

  # persistence
  save:       ()-> (@Service.save @)
  delete:     ()-> (@Service.delete @)
  # update: (atts)-> (@Service.udpate @, atts)
  # updateAttribute: (field, value)-> (@Service.udpateAttributes @, field, value)

  toJSON: () -> 
    JSON.stringify @_attributes

  toEvent: () -> 
    atts = merge {}, @_attributes # copy for modification
    delete atts[_refIds]
    (atts[objName] = obj.toEvent() if obj?.toEvent?() ) for own objName, obj of @_refs
    atts

  emitTo: (channel) ->
    if channel.manager?.settings?.transports? # send attributes when emitting over socket.io
      channel.emit @className(), @toEvent()
    else                                      # send model object when emitting through EventEmitter
      channel.emit @className(), @

module.exports = ModelBase
