
{Parser} = require 'jison'

{unwrap, jison_dsl: o} = require './Helper'

grammar =
  
  Root: [
    o '', -> new Body ''
    o 'Body'
  ]
  
  Body: [
    o 'Zenspression', -> new Body $1
    o 'Body Zenpression', -> $1.push $2
  ]
   
  Zenspression: [
   o 'ZenTag'
   o 'ZenOperation'
   o 'ZenAlias'
  ]
  
  Parenthetical: [
    o '( Body )', -> $2
  ]
  
  ZenOperation: [
    o 'Zenspression ZEN_OPERATOR Zenspression', -> $1.push $2, $3
  ]
  
  ZenTag: [
    o 'HtmlTag', -> new ZenTag $1
  ]

  HtmlTag: [
    o 'ELEMENT AbbreviatedAttributeList AttributeList', -> new HtmlTag $1, $2, $3
    o 'ELEMENT AbbreviatedAttributeList AttributeList ZEN_POPULATOR', -> new HtmlTag $1, $2, $3, $4
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
