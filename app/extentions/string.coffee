###
Sources:
http://jamesroberts.name/blog/2010/02/22/string-functions-for-javascript-trim-to-camel-case-to-dashed-and-to-underscore/
###

String::upcase ||= -> @toUpperCase()

# trim
String::trim ||= ()->
  @replace /^\s+|\s+$/g, ""

# ltrim
String::ltrim ||= ()->
  @replace /^\s+/g, ""

# rtrim
String::rtrim ||= ()->
  @replace /\s+$/g, ""

# array of tokens
String::tokens ||= (delim) ->
  list = @split(delim)
  list = (item.trim() for item in list)
  
# toCamel
String::toCamel ||= ()->
  @replace /(\-[a-z])/g, ($1)->
    $1.toUpperCase().replace('-','')

# dasherize
String::toDash ||= ()->
  @replace /([A-Z])/g, ($1)->
    return "-"+$1.toLowerCase()

#underscore
String::toUnderscore ||= ()-> 
  @replace /([A-Z])/g, ($1)->
    "_"+$1.toLowerCase()

# titleCase
String::toTitleCase ||= ()->
  @replace /(?:^|\s)\w/g, ($1)->
    $1.toUpperCase()

# file-name.coffee -> ClassName
String::toClassName = ()->
  (@replace '.coffee','').toCamel().toTitleCase()
