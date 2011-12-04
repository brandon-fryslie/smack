
{_h} = require './Helper'

SINGLETONS = ['area', 'base', 'br', 'col', 'command', 'embed', 'hr', 'img', 'input', 'link', 'meta', 'param', 'source']

ATTR_ABBR_LOOKUP =
  '#': 'id'
  '.': 'class'
    
ALIAS_LOOKUP =
  iframe: 'iframe style="width:0;height:0;" src=""'

exports.Node = class Node
  
  constructor: (@nodes = []) ->
  
  push: (node) -> @nodes.push node
  
  # Passes each child to a function, breaking when the function returns `false`.
  # eachChild: (func) ->
  #   for name, prop of @
  #     if typeof prop isnt 'function'
  #       return this if func(node) is false
  #   this
  
  # string representation of the node, for inspecting the parse tree.
  # to_s: (idt = '', name = @constructor.name) ->
  #   tree = '\n' + idt + name
  #   tree += '?' if @soak
  #   @eachChild (node) -> tree += node.toString idt + TAB
  #   tree

exports.Body = class Body extends Node
    
  compile: ->
    (n.compile() for n in @nodes).join ''
    
exports.SmackBlock = class SmackBlock extends Node
       
  constructor: (@front_op, @zentag, @content, @rear_op) ->
           
  compile: ->
    [head, foot ] = @zentag.compile()

    "#{head}#{@content}#{foot}"
   
exports.ZenTag = class ZenTag extends Node
  
  constructor: (tag) -> 
    @tags = [op: '>', tag: tag]
  
  add: (op, tag) ->
    @tags.push op: tag
  
  compile: ->
    tag_stack = []
    tag_c_stack = []
    for { op, tag } in @tags
      tag_c_stack.push tag.compile()
      switch op
        when '>'
          tag_stack.push tag.el
        when '+'
          tag_stack.splice -1, 0, tag.el
    
    head = tag_c_stack.join ''
        
    close_tags = ('</'+t+'>' while t = tag_stack.pop() when t not in SINGLETONS)
      
        
    foot = close_tags.join('')
    
    [ head, foot ]
      
   
exports.HtmlTag = class HtmlTag extends Node
  
  constructor: (@el, @abbreviated, @attributes) ->
    
  compile: ->
    attrs = {}  

    attrs[key] = value for { key, value } in @attributes
    
    for { key, value } in @abbreviated
      key = ATTR_ABBR_LOOKUP[key]
      if attrs[key]? and key is 'class'
        attrs[key] += ' '+value
      else
        attrs[key] = value
    
    id_class_s = (' '+k+'="'+v+'"' for k, v of attrs when k is 'id' or k is 'class').join ''
    attr_s     = (' '+k+'="'+v+'"' for k, v of attrs when k isnt 'id' and k isnt 'class').join ''
    
    "<#{@el}#{id_class_s}#{attr_s}>"
    
exports.Literal = class Literal extends Node
    
  constructor: (@value) ->

  compile: -> "#{@value}"

# exports.Op = class Op extends Node
  
  # constructor: (@op, @first, @second) ->
    
  # compile: ->
    # if @op is '+' then console.log @first
