
{Parser} = require 'jison'

{unwrap, jison_dsl: o} = require './Helper'

grammar =
  
  Root: [
    o 'Body'
  ]
  
  Body: [
    o 'Zenspression', -> new ZenTag $1
    o 'Body Zenspression', -> $1.push $2
  ]
   
  Zenspression: [
   o 'HtmlTag'
   o 'ZEN_OPERATOR'
   o 'ZenAlias'
  ]
  
  # Parenthetical: [
  #   o '( ZenTag )', -> $2
  # ]

  HtmlTag: [
    o 'ELEMENT', ->
        new HtmlTag $1
    o 'ELEMENT Attributes', ->
        new HtmlTag $1, $2
    o 'ELEMENT TAG_CONTENT', ->
        new HtmlTag $1, null, $2
    o 'ELEMENT TAG_CONTENT Attributes', ->
        new HtmlTag $1, $2, $3
    o 'TAG_FRONT_CONTENT ELEMENT', ->
        new HtmlTag $2, null, $1
    o 'TAG_FRONT_CONTENT ELEMENT Attributes', ->
        new HtmlTag $2, $3, $1
  ]
  
  Attributes: [
    o 'ATTRIBUTE', -> [$1]
    o 'Attributes ATTRIBUTE', -> $1.concat $2
  ]

operators = []

tokens = []
for name, alternatives of grammar
  grammar[name] = for alt in alternatives
    for token in alt[0].split ' '
      tokens.push token unless grammar[token]
    alt[1] = "return #{alt[1]}" if name is 'Root'
    alt

exports.zen_parser = new Parser
  tokens      : tokens.join ' '
  bnf         : grammar
  operators   : operators.reverse()
  startSymbol : 'Root'
