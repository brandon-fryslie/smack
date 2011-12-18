{ZenLexer}  = require './ZenLexer'
{parser}    = require './ZenParser'
{extend}    = require './Helper'
ZenConfig   = require './ZenConfig'

exports.compile = compile = (code, options = {}) ->
	try
    (parser.parse lexer.tokenize code).compile options
  catch e
    console.log 'tokens',lexer.tokenize code
    console.log e.message || e
    code

exports.tokens = (code, options) ->
  lexer.tokenize code, options

exports.nodes = nodes = (source, options) ->
  if typeof source is 'string'
    parser.parse lexer.tokenize source, options
  else
    parser.parse source

exports.leaves = (source, o) ->
  nodes(source).leaves(o)

lexer = new ZenLexer

parser.lexer =
  lex: -> [tag, @yytext, @yylineno] = @tokens[@pos++] or [''];tag
  setInput: (@tokens) -> @pos = 0
  upcomingInput: -> ""

parser.yy = require './ZenAST'

extend exports, ZenConfig