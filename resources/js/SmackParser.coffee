
{Parser} = require('jison')

unwrap = /^function\s*\(\)\s*\{\s*return\s*([\s\S]*);\s*\}/

# Our handy DSL for Jison grammar generation, thanks to
# [Tim Caswell](http://github.com/creationix). For every rule in the grammar,
# we pass the pattern-defining string, the action to run, and extra options,
# optionally. If no action is specified, we simply pass the value of the
# previous nonterminal.
o = (patternString, action, options) ->
  patternString = patternString.replace /\s{2,}/g, ' '
  return [patternString, '$$ = $1;', options] unless action
  action = if match = unwrap.exec action then match[1] else "(#{action}())"
  action = action.replace /\bnew /g, '$&yy.'
  action = action.replace /\b(?:Block\.wrap|extend)\b/g, 'yy.$&'
  [patternString, "$$ = #{action};", options]

grammar =
  
  Root: [
    o '', -> new Body [$1]
    o 'Body'
  ]
  
  Body: [
    o 'Expression', -> new Body [$1]
    o 'Body Expression', -> $1.push $2
  ]
    
  Expression: [
    o 'SmackBlock'
  ]
  
  SmackBlock: [
    o 'OPENTAG SMACK_OPERATOR SmackTagConfig MIDTAG LITERAL SMACK_OPERATOR CLOSETAG', ->
      new SmackBlock $2, $3, $5, $6
    o 'OPENTAG SMACK_OPERATOR LITERAL MIDTAG SmackTagConfig SMACK_OPERATOR CLOSETAG', ->
      new SmackBlock $2, $5, $3, $6
  ]
  
  SmackTagConfig: [
    o 'ZenTag'
  ]
  
  ZenTag: [
    o 'HtmlTag', -> new ZenTag $1
    o 'ZenTag ZEN_OPERATOR HtmlTag', -> $1.tags.push {op: $2, tag: $3}; $1
  ]

  HtmlTag: [
    o 'ELEMENT AbbreviatedAttributeList AttributeList', -> new HtmlTag($1, $2, $3)
  ]

  AbbreviatedAttributeList: [
    o '', -> []
    o 'AbbreviatedAttributes', -> $1
  ]
  
  AbbreviatedAttributes: [
    o 'ABBREVIATED_ATTRIBUTE', -> [$1]
    o 'AbbreviatedAttributes ABBREVIATED_ATTRIBUTE', -> $1.concat $2
  ]
  
  AttributeList: [
    o '', -> []
    o 'ATTR_LIST_OPEN Attributes ATTR_LIST_CLOSE', -> $2
  ]
  
  Attributes: [
    o 'ATTRIBUTE', -> [$1]
    o 'Attributes ATTRIBUTE', -> $1.concat $2
  ]
  
  ###

  *** Smack Grammar ***

  Root -> Body

  Body ->
      Smack_Tag
    | Smack_Tag Body

  Smack_Tag ->
      OPENTAG Smack_Tag_Config Literal CLOSETAG
    | OPENTAG Literal Smack_Tag_Config CLOSETAG

  Smack_Tag_Config ->
      HtmlTag
    | HtmlTag ZEN_OPERATOR HtmlTag

  HtmlTag ->
      ELEMENT HTML_ID HTML_CLASSES HTML_ATTRIBUTES

###

operators = []

# Wrapping Up
# -----------
# console.log grammar

# Finally, now that we have our **grammar** and our **operators**, we can create
# our **Jison.Parser**. We do this by processing all of our rules, recording all
# terminals (every symbol which does not appear as the name of a rule above)
# as "tokens".
tokens = []
for name, alternatives of grammar
  grammar[name] = for alt in alternatives
    try
      alt[0].split ' '
    catch e
      console.log "alt[0] invalid in: #{alt}"
    try
      for token in alt[0].split ' '
        tokens.push token unless grammar[token]
    catch e
      console.log "alt[0] invalid in: #{alt}"
      console.log e
    alt[1] = "return #{alt[1]}" if name is 'Root'
    alt

# Initialize the **Parser** with our list of terminal **tokens**, our **grammar**
# rules, and the name of the root. Reverse the operators because Jison orders
# precedence from low to high, and we have it high to low
# (as in [Yacc](http://dinosaur.compilertools.net/yacc/index.html)).
exports.parser = new Parser
  tokens      : tokens.join ' '
  bnf         : grammar
  operators   : operators.reverse()
  startSymbol : 'Root'
  
if module? and not module.parent?
  _ = require 'underscore'
  {SmackLexer} = require('./SmackLexer.coffee')
  parser = exports.parser
  parser.yy = require './SmackNodes'
  
  # Mixin assert
  t = this
  @[k] = v for k, v of require 'assert'

  ok = @['ok']

  lexer = new SmackLexer
  # tokens = lexer.tokenize('~|> p#status.block-message |alt:Bla Bla Bla| > div.clear-fix~ Upload Successful! |~')
  
  parser.lexer =
    lex: ->
      [tag, @yytext] = @tokens[@pos++] or ['']
      tag
    setInput: (@tokens) ->
      @pos = 0
    upcomingInput: ->
      ""
  #     
  # tokens = [[ 'ATTR_ABBR_OPERATOR', '#' ],
  #       [ 'ATTR_ABBR_VALUE', 'status' ],
  #       [ 'ATTR_ABBR_OPERATOR', '.' ],
  #       [ 'ATTR_ABBR_VALUE', 'block-message' ],
  #       [ 'ATTRIBUTE_LIST', 'alt:Bla Bla Bla' ]]
  # 
  
  tokens = lexer.tokenize('~|> p#dialog.clearfix.poopbutt |target: http://www.fart.com| > span.error ~ Upload Successful! |~')
  tokens = lexer.tokenize('~|> p~ |~')
  # console.log tokens  
  console.log parser.parse(tokens).compile()


  # try
  # tokens = lexer.tokenize('~|> p#status.block-message |alt:Bla Bla Bla| > div.clear-fix~ Upload Successful! |~')
  # console.log  tokens
  # console.log parser.parse(tokens).compile()
    
  # console.log lexer.tokenize('~| Upload Successful! ~>p#status.block-message |alt:Bla Bla Bla| > div.clear-fix |~')
