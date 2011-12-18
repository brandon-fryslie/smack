
{extend, trim} = require './Helper'

SINGLETONS = ['area', 'base', 'br', 'col', 'command', 'embed', 'hr', 'img', 'input', 'link', 'meta', 'param', 'source']

class Config
  constructor: (@lookup = {}) ->
    
  contains: (item) ->
    item of @lookup
  
  set: (items) ->
    extend @lookup, items
    
  remove: (items) ->
    delete @lookup[item] for item in items
  
  resolve: (item) ->
    return @lookup[item]
    
StdAliases =
  input_box: -> '> div.clearfix > div.input > label'
  topbar: (args) ->
    [brand] = args
    """
      div.topbar
        > div.fill
          > div.container-fluid
            > '#{brand}' a.brand:#
    """

class Aliases extends Config  
  resolve: (identifier, args) ->
    throw "Undefined alias: "+identifier unless identifier of @lookup
    args = (trim a for a in args.split ',')
    @lookup[identifier](args)

StdDefaultAttributes =
  img     : { alt   : '' }
  input   : { type  : 'text' }
  link    : { rel   : 'stylesheet' }
  iframe  : { style : 'border:0;width:0px;height:0px' }
  
class DefaultAttributes extends Config
  resolve: (el) ->
    return extend {}, @lookup[el]
  
StdPrimaryAttributes =
  a       : 'href'
  script  : 'src'
  img     : 'src'
  link    : 'href'
  input   : 'value'
  form    : 'action'

primary_attributes = new Config StdPrimaryAttributes

StdAbbreviations =
  '#'  : 'id'
  '.'  : 'class'
  '::' : 'type'
  '4'  : 'for'
  '+'  : 'target'
  '='  : 'value'
  '!'  : 'action'

class Abbreviations extends Config  
  resolve: (abbreviation, el) ->
    return @lookup[abbreviation] if abbreviation of @lookup
    return primary_attributes.resolve(el) if abbreviation is ':' and primary_attributes.contains el
    match = /^&([a-z\-]+):/.exec abbreviation
    return "data-#{match[1]}" if match?[1]?
    abbreviation


exports.IS_SINGLETON = (el) -> el in SINGLETONS
exports.ALIAS = new Aliases StdAliases
exports.ABBREVIATION = new Abbreviations StdAbbreviations
exports.ATTRIBUTE = 
  defaults: new DefaultAttributes StdDefaultAttributes
  primary: primary_attributes
exports.VARIABLE = new Config
