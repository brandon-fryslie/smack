
{trim, visit, flatten, print_tree, last} = require './Helper'

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
  
  push: (tag) ->
    @tags.push tag
    this
    
  treeify: (o = {}) ->
    root = children: [], name: 'root'
    current = root
    parents = []
    
    while (tag = @tags.shift())
      switch tag
        when '>'
          parents.push current
          current = last current.children
        when '<'
          current = parents.pop() or root
        when '#'
          current = root
        when '!'
          if temp_current?
            current = temp_current
            temp_current = null
          else
            temp_current = current
            current = children: []
        when '+'
          'noop'
        else
          current.children.push tag
    @root = root
    
  leaves: ->
    @treeify() unless @root?
    flatten (t.leaves() for t in @root.children)    
    
  compile: (o = {}) ->
    @treeify() unless @root?
    (t.compile(o) for t in @root.children).join ''
   
exports.HtmlTag = class HtmlTag extends Node
  
  constructor: (@el, @attributes = [], @content = '') ->
    @children = [] unless @el in SINGLETONS
  
  set_content: (s) ->
    @content = s
  
  leaves: ->
    return this if @children.length is 0 and @content is ''
    c.leaves() for c in @children if @children?
    
  compile: (o) ->
    attrs = {}
    
    for { key, value } in @attributes
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
    
