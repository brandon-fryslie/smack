
if module?
  CoffeeScript    = require 'coffee-script'
  fs              = require 'fs'                    
  path            = require 'path'                  
  {SmackLexer}    = require './SmackLexer'          
  {parser}        = require './SmackParser'
  exports.VERSION = '0.0.1'


lexer = new SmackLexer
# The real Lexer produces a generic stream of tokens. This object provides a
# thin wrapper around it, compatible with the Jison API. We can then pass it
# directly as a "Jison lexer".
parser.lexer =
  lex: ->
    [tag, @yytext] = @tokens[@pos++] or ['']
    tag
  setInput: (@tokens) ->
    @pos = 0
  upcomingInput: ->
    ""

# Compile a string of code to JavaScript, using the Jison
# compiler.
exports.compile = compile = (code, options = {}) ->
  try
    (parser.parse lexer.tokenize code).compile options
  catch err
    err.message = "In #{options.filename}, #{err.message}" if options.filename
    throw err

# Tokenize a string of CoffeeScript code, and return the array of tokens.
exports.tokens = (code, options) ->
  lexer.tokenize code, options

# Parse a string of CoffeeScript code or an array of lexed tokens, and
# return the AST. You can then compile it by calling `.compile()` on the root,
# or traverse it by using `.traverse()` with a callback.
exports.nodes = (source, options) ->
  if typeof source is 'string'
    parser.parse lexer.tokenize source, options
  else
    parser.parse source

parser.yy = require './SmackNodes'

# Loader for CoffeeScript as a Node.js library.
# exports[key] = val for key, val of @
# log exports