
{trim, visit, flatten, print_tree, last, extend, indent} = require './Helper'

{IS_SINGLETON, ATTRIBUTE, ABBREVIATION} = require './ZenConfig'

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
          tag.parent = current
          current.children.push tag
    @root = root
    
  leaves: (o) ->
    @treeify() unless @root?
    flatten (t.leaves(o) for t in @root.children)
    
  compile: (o = {}) ->
    @treeify() unless @root?
    (t.compile(o) for t in @root.children).join ''
   
exports.HtmlTag = class HtmlTag extends Node
  
  constructor: (@el, @attributes = [], @content = '') ->
    @is_singleton = IS_SINGLETON @el
    @children = [] unless @is_singlton
  
  copy: (content) ->
    tag = new HtmlTag @el, ({ key, value } for { key, value } in @attributes)
    tag.children.push c.copy content for c in @children unless @is_leaf() or @is_singlton
    tag.set_content content
  
  set_content: (s) ->
    return @ if @is_singlton
    (@content = s; return @) if @is_leaf      
    c.set_content s for c in @children
    @

  is_leaf: ->
    @children.length is 0
  
  leaves: (o) ->
    if o.empty
      return this if @is_leaf() and @content is ''
    else
      return this if @is_leaf()  
    c.leaves(o) for c in @children if @children?
    
  compile: (o) ->
    attrs = ATTRIBUTE.defaults.resolve @el
    
    for { key, value } in @attributes
      key = ABBREVIATION.resolve key, @el
      if attrs[key]? and key is 'class'
        attrs['class'] += ' '+value
      else
        attrs[key] = value
        
    id_class_s = ''
    id_class_s += " id=\"#{attrs.id}\"" if attrs.id?
    id_class_s += " class=\"#{attrs.class}\"" if attrs.class?
          
    attr_s     = (' '+k+'="'+v+'"' for k, v of attrs when k isnt 'id' and k isnt 'class').join ''
    foot_str   = if @is_singleton then '' else '</'+@el+'>'
    
    if @children?.length
      o.indent_lvl += 1 if o.indent
      content_str = (c.compile(o) for c in @children if @children?).join ''
    else if o.leaves?
      content_str = "~:$#{node_idx++}:~"
    else
      content_str = @content
    
    dent = if o.indent then indent(o.indent_lvl) else ''
    newline = if o.indent then "\n" else ''
    
    "#{dent}<#{@el}#{id_class_s}#{attr_s}>#{newline}#{content_str}#{foot_str}#{newline}"
