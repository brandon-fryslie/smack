                            
{Lexer}   = require './Lexer'
{parser}  = require './Parser'
Zen       = require './Zen'
{extend}  = require './Helper'

# {ATTR_ABBR_LOOKUP} = require './AST'

exports.VERSION = '0.0.2'

exports.compile = compile = (code, options = {}) ->
  (parser.parse lexer.tokenize code).compile options

exports.tokens = (code, options) ->
  lexer.tokenize code, options

exports.nodes = (source, options) ->
  if typeof source is 'string'
    parser.parse lexer.tokenize source, options
  else
    parser.parse source

exports.Zen = Zen

lexer = new Lexer

parser.lexer =
  lex: -> [tag, @yytext] = @tokens[@pos++] or ['']; tag
  setInput: (@tokens) -> @pos = 0
  upcomingInput: -> ""

parser.yy = require './AST'
    
exports.attr_abbr = (abbrs) ->
  extend ATTR_ABBR_LOOKUP, abbrs
    
exports.remove_abbr = (abbrs) ->
  delete ATTR_ABBR_LOOKUP[abbr] for abbr in abbrs

exports.attr_abbrs = ->
  ATTR_ABBR_LOOKUP
