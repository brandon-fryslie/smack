
{trim, visit, flatten, print_tree} = require './Helper'

SINGLETONS = ['area', 'base', 'br', 'col', 'command', 'embed', 'hr', 'img', 'input', 'link', 'meta', 'param', 'source']

exports.POPULATOR_BANK = POPULATOR_BANK = {}

exports.ATTR_ABBR_LOOKUP = ATTR_ABBR_LOOKUP =
  '#'  : 'id'
  '.'  : 'class'
  '4'  : 'for'
  '+'  : 'target'
  '='  : 'value'
  '!'  : 'action'
  '$'  : 'name'
  '::' : 'type'

RESOLVE_ATTR_ABBR = (abbreviation) ->
    
  return ATTR_ABBR_LOOKUP[abbreviation] if abbreviation of ATTR_ABBR_LOOKUP

  match = /^&([a-z\-]+):/.exec abbreviation
  
  return "data-#{match[1]}" if match?[1]?
  
  throw "AST says invalid attribute abbreviation: #{abbreviation}"
    
exports.ALIAS_BANK = ALIAS_BANK =
  bs:
    input_box: '> div.clearfix >  div.input > label'

node_idx = 1

Node = class Node
  
  # constructor: (@children = []) ->
  
  # push: (node) -> @children.push node; this

exports.Body = class Body extends Node
  
  constructor: (@expressions) ->
    @children = ['expressions']
    
  leaves: ->
    # console.log 'ZenAST Body Expressions:', @expressions
    flatten @expressions.leaves()
    
  compile: (o) ->
    o ?= {}
    (@[n].compile(o) for n in @children).join ''

exports.Parens = class Parens extends Node
  constructor: (@body) ->
    
  children: ['body']

  compile: (o) ->
    @body.compile o

exports.ZenTag = class ZenTag extends Node
  
  # Here:
  # Get entire zen tag
  # compile it
  # zen parser will replace @aliases and handle that
  # get back a tree of html nodes:
  #
  constructor: (tag) ->
    @tags = [tag]
  
  push: (zen_op, zen_tag) ->
    switch zen_op
      when '>'
        @tags[@tags.length-1].children = @tags[@tags.length-1].children.concat(zen_tag.tags)
      when '+'
        @tags = @tags.concat zen_tag.tags
        # console.log "@tags: ", @tags
    this
    
  leaves: ->
    (if t.children.length then t.leaves() else t) for t in @tags when t.children?
    
  compile: (o) ->
    (t.compile(o) for t in @tags).join ''
   
exports.HtmlTag = class HtmlTag extends Node
  
  constructor: (@el, @abbreviated, @attributes, @populator) ->
    @content = ''
    @children = [] unless @el in SINGLETONS
  
  set_content: (s) -> 
    @content = s
  
  leaves: ->
    return this if @children.length is 0
    c.leaves() for c in @children
    
  compile: (o) ->
    attrs = {}

    attrs[key] = value for { key, value } in @attributes
    
    for { key, value } in @abbreviated
      key = RESOLVE_ATTR_ABBR(key)
      if attrs[key]? and key is 'class'
        attrs['class'] += ' '+value
      else
        attrs[key] = value
    
    id_class_s = ''
    id_class_s += " id=\"#{attrs.id}\"" if attrs.id?
    id_class_s += " class=\"#{attrs.class}\"" if attrs.class?
          
    attr_s     = (' '+k+'="'+v+'"' for k, v of attrs when k isnt 'id' and k isnt 'class').join ''
    foot_str   = if @el in SINGLETONS then '' else '</'+@el+'>'
    
    if @children?.length
      content_str = (c.compile(o) for c in @children if @children?).join ''
    else if @populator?
      content_str = @populator
    else if o.leaves?
      content_str = "~|$#{node_idx++}|~"
    else
      content_str = @content
    
    "<#{@el}#{id_class_s}#{attr_s}>#{content_str}#{foot_str}"
    
