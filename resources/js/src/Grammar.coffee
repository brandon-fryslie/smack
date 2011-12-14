
{Parser} = require 'jison'

{unwrap, jison_dsl: o} = require './Helper'

grammar =
  
  Root: [
    o '', -> new Body ''
    o 'Body'
  ]
  
  Body: [
    o 'Smaxpression', -> new Body [$1]
    o 'Body Smaxpression', -> $1.push $2
  ]
    
  Smaxpression: [
    o 'SmackBlock'
    o 'UNTOUCHABLE', -> new Literal $1
  ]
  
  SmackBlock: [
    o 'OPENTAG SMACK_OPERATOR ZENTAG MIDTAG TagContents SMACK_OPERATOR CLOSETAG', ->
        new SmackBlock $2, new ZenTag($3), $5, $6
    o 'OPENTAG SMACK_OPERATOR TagContents MIDTAG ZENTAG SMACK_OPERATOR CLOSETAG', ->
        new SmackBlock $2, new ZenTag($5), $3, $6
    o 'OPENTAG SMACK_OPERATOR ZENTAG SMACK_OPERATOR CLOSETAG', ->
        new SmackBlock $2, new ZenTag($3), [], $4
  ]
  
  TagContents: [
    o 'TagContent', -> [$1]
    o 'TagContents TagContent', -> $1.concat $2
  ]
  
  TagContent: [
    o 'LITERAL', -> new Literal $1
    o 'SMACK_VARIABLE', -> new SmackVariable $1
    o 'SmackBlock'
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
