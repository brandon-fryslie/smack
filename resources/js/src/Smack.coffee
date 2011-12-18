                            
{Lexer}   = require './Lexer'
{parser}  = require './Parser'
{extend}  = require './Helper'

exports.Zen = Zen = require './Zen'

exports.VERSION = '0.0.7'

exports.compile = compile = (code, options = {}) ->
  try
    (parser.parse lexer.tokenize code).compile options
  catch e
    console.log 'tokens',lexer.tokenize code
    console.log e.message || e
    code

exports.tokens = (code, options) ->
  lexer.tokenize code, options

exports.nodes = (source, options) ->
  if typeof source is 'string'
    parser.parse lexer.tokenize source, options
  else
    parser.parse source

lexer = new Lexer

parser.lexer =
  lex: -> [tag, @yytext] = @tokens[@pos++] or ['']; tag
  setInput: (@tokens) -> @pos = 0
  upcomingInput: -> ""

parser.yy = require './AST'
    
exports.abbreviation = (abbrs) ->
  extend ABBREVIATION_LOOKUP, abbrs
    
exports.remove_abbr = (abbrs) ->
  delete ABBREVIATION_LOOKUP[abbr] for abbr in abbrs

exports.abbreviations = ->
  ABBREVIATION_LOOKUP

exports.var = Zen.var

exports.remove_var = Zen.remove_var