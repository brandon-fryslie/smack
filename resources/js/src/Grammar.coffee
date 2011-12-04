
{Parser} = require('jison')

unwrap = /^function\s*\(\)\s*\{\s*return\s*([\s\S]*);\s*\}/

# Our handy DSL for Jison grammar generation, thanks to
# [Tim Caswell](http://github.com/creationix). For every rule in the grammar,
# we pass the pattern-defining string, the action to run, and extra options,
# optionally. If no action is specified, we simply pass the value of the
# previous nonterminal.
# 
# Talk about a feature packed couple of lines.  This converts all rhs functions into strings
# then does some regex magic on them to get them into Jison form
o = (patternString, action, options) ->
  patternString = patternString.replace /\s{2,}/g, ' '
  return [patternString, '$$ = $1;', options] unless action
  action = if match = unwrap.exec action then match[1] else "(#{action}())"
  action = action.replace /\bnew /g, '$&yy.'
  action = action.replace /\b(?:Block\.wrap|extend)\b/g, 'yy.$&'
  [patternString, "$$ = #{action};", options]

grammar =
  
  Root: [
    o '', -> new Body
    o 'Body'
  ]
  
  Body: [
    o 'Expression', -> new Body [$1]
    o 'Body Expression', -> $1.push $2; $1
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

operators = []

# Wrapping Up
# -----------

# Create Jison Parser from grammar above, first recording all the terminals (tokens)
tokens = []
for name, alternatives of grammar
  grammar[name] = for alt in alternatives
    for token in alt[0].split ' '
      tokens.push token unless grammar[token]
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
