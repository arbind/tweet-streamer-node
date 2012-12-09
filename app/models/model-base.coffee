mixinKeywords = ['extended', 'included']

class ModelBase
  _attributes: null
  _refs: null

  @extend: (obj) ->
    @[key] = value for key, value of obj when key not in mixinKeywords
    obj.extended?.apply(@)
    @

  @include: (klazz) -> # Assign properties to the prototype
    @::[key] = value for key, value of klazz when key not in mixinKeywords
    klazz.included?.apply(@)
    @

  # ORM service 
  @_ORMService: null
  @ORM: ()->
    return @_ORMService if @_ORMService?
    @_ORMService = @::['ORM'] if @::['ORM']?
    return @_ORMService if @_ORMService
    ormServiceName = @::['constructor'].name + "ORM"
    @_ORMService = global[ormServiceName] if global[ormServiceName]?
    return @_ORMService if @_ORMService
    throw "No ORM Service found!"

  # ORM: class methods
  @find:     (info, callback)-> @ORM().find info, callback
  @findById:   (id, callback)-> @ORM().findById id, callback
  @findAll:       (callback) -> @ORM().findAll callback

  # ORM: instance methods
  save:     (callback)=> @constructor.ORM().save @, callback
  destroy:  (callback)=> @constructor.ORM().destroy @, callback
  update: (newAtts, callback)-> @constructor.ORM().update @, newAtts, callback
  updateAttribute: (field, newValue, callback)-> @constructor.ORM().updateAttribute @, field, newValue, callback

  # BaseClass class methods
  constructor: (attributes) ->
    @_attributes = attributes || {}
    @_refs = {}
    @_loadRefs()

    # console.log @_attributes
    throw "These attributes must be a hash not #{@_attributes.constructor.name}" unless @_attributes.isHash()
    return unless attributes? and isPresent(attributes)
    @setFields attributes

  # BaseClass instance methods
  className: ()=> @constructor.name

  id: ()=> @get('id')

  get: (attName) => 
    @_attributes[attName] || @_getRef(name) || null

  set: (attName, value) => 
    return unless attName
    if value instanceof ModelBase
      @_setRef(attName, value)
    else
      @_attributes[attName] = value

  setFields: (atts) => (@set field, atts[field] if atts[field]?) for field in @classFieldNames if atts?

  _setRef: (name, obj)=>
    @_attributes._refIds ||= {}
    @_attributes._refIds[name] = obj.id()
    @_refs[name] = obj

  _getRef: (name)=>
    return @_refs[name] if @_refs[name]?        # return the object if it is already loaded
    return null unless @_attributes._refIds[name]?          # return null if there is no object or refId for this name
    @_refs[name] = @_loadRef(name, @_attributes._refIds[name]) # load the actual object if there is a refId

  _loadRefs: ()=> # recursively load all refs
    return unless @_attributes._refIds # nothing to load if there are no refIds
    return if @_attributes._refIds.keys().length is @_refs.keys().length  # return if refs are already loaded
    nextRef = null # find the next ref that needs to be loaded:
    (nextRef ||= refName unless @_refs[refName]?) for refName, refId in @_attributes._refIds
    @_loadRef name, @_attributes._refIds[name], (err, obj) =>
      @_refs[name] = obj || null
      @_loadRefs() # recursively load all refs

  _loadRef: (name, id, callback)=>
    svcClassName = name.toTitleCase()+"Service"
    svcClass = global[svcClassName]  
    svcClass.find id, callback

  toJSON: () => 
    JSON.stringify @_attributes

  toEvent: () => 
    atts = Object.merge {}, @_attributes # copy for modification

    # remove private fields
    delete atts[fieldName] for fieldName in @privateFields if @privateFields?

    # add object relationships
    delete atts['_refIds']
    (atts[objName] = obj.toEvent() if obj?.toEvent?() ) for own objName, obj of @_refs
    atts

  emitTo: (channel) =>
    if channel.manager?.settings?.transports? # send attributes when emitting over socket.io
      channel.emit @className(), @toEvent()
    else                                      # send model object when emitting through EventEmitter
      channel.emit @className(), @

module.exports = ModelBase
