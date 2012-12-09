global.extendMixin = (obj, mixin) ->
  obj[name] = method for name, method of mixin        
  obj

global.includeMixin = (clazz, mixin) ->
  extendMixin clazz.prototype, mixin
