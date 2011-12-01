if module?
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

exports.Body = class Body extends Node
    
  compile: ->
    (n.compile() for n in @nodes).join('')
    
exports.SmackBlock = class SmackBlock extends Node
       
  constructor: (@front_op, @zentag, @literal, @rear_op) ->
       
  compile: ->
    [head, foot, indent] = @zentag.compile()

    "#{head}#{indent}#{@literal}#{'\n' if indent isnt ''}#{foot}"
   
exports.ZenTag = class ZenTag extends Node
  
  constructor: (tag) -> @tags = [op: '>', tag: tag]
  
  add: (op, tag) ->
    @tags.push op: tag
  
  compile: ->
    tag_stack = []
    tag_c_stack = []
    lvl = 0 # Set to -1 to turn off indenting
    should_indent = lvl isnt -1
    for { op, tag } in @tags
      tag_c_stack.push if should_indent then _h.indent(lvl)+tag.compile()+'\n' else tag.compile()
      switch op
        when '>'
          tag_stack.push tag.el
          lvl++
        when '+'
          tag_stack.splice -1, 0, tag.el
    
    # indent level for stuff in the block
    content_lvl = lvl+1
    head = tag_c_stack.join('')
        
    close_tags = while t = tag_stack.pop() when t not in SINGLETONS
      '</'+t+'>' unless should_indent
      _h.indent(--lvl)+"</#{t}>\n"
        
    foot = close_tags.join('')
    
    [ head, foot, if should_indent then _h.indent(content_lvl) else '' ]
      
   
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
    
    id_class_s = _h.join (' '+k+'="'+v+'"' for k, v of attrs when k is 'id' or k is 'class')
    attr_s     = _h.join (' '+k+'="'+v+'"' for k, v of attrs when k isnt 'id' and k isnt 'class')
    
    "<#{@el}>" unless attrs?
    "<#{@el}#{id_class_s}#{attr_s}>"
    
exports.Literal = class Literal extends Node
    
  constructor: (@value) ->

  compile: -> "#{@value}"

# exports.Op = class Op extends Node
  
  # constructor: (@op, @first, @second) ->
    
  # compile: ->
    # if @op is '+' then console.log @first

if module? and not module.parent?
  _ = require 'underscore'
  _.mixin require 'underscore.inspector'
  {SmackLexer} = require('./SmackLexer.coffee')
  {parser} = require('./SmackParser.coffee')

  
  parser.yy = require './SmackNodes'
  
  # Mixin assert
  t = this
  @[k] = v for k, v of require 'assert'

  ok = @['ok']

  lexer = new SmackLexer
  # tokens = lexer.tokenize('~|> p#status.block-message |alt:Bla Bla Bla| > div.clear-fix~ Upload Successful! |~')
  
  parser.lexer =
    
    lex: -> [tag, @yytext] = @tokens[@pos++] or ['']; tag
    
    setInput: (@tokens) -> @pos = 0
    
    upcomingInput: -> ""
  
  # tokens = lexer.tokenize('~|> p#dialog.clearfix.poopbutt |target: http://www.fart.com| > span.error~ Upload Successful! |~')

  # tokens = lexer.tokenize('~| Upload Successful! ~p#dialog.clearfix.poopbutt |target: http://www.fart.com| > span.error |~')
  
  # tokens = lexer.tokenize('~|> p#status.block-message |alt:Bla Bla Bla| > div.clear-fix~ Upload Successful! |~')

  # Stage 1
  # tokens = lexer.tokenize('~|> p~ Upload Successful! |~')
  
  # tokens = lexer.tokenize('~|> p#dialog.clearfix.poopbutt |target: http://www.fart.com| > span.error~ Upload Successful! |~')
  # console.log tokens
  # console.log parser.parse(tokens).compile()
