{ZenLexer}       = require './ZenLexer'
{parser}         = require './ZenParser'
{ALIAS_BANK}     = require './ZenAST'
{VARIABLE_BANK}  = require './ZenAST'
{extend}         = require './Helper'

exports.compile = compile = (code, options = {}) ->
  (parser.parse lexer.tokenize code).compile options

exports.tokens = (code, options) ->
  lexer.tokenize code, options

exports.nodes = nodes = (source, options) ->
  if typeof source is 'string'
    parser.parse lexer.tokenize source, options
  else
    parser.parse source

exports.leaves = (nodes, options) ->
  nodes(source, options).leaves()

lexer = new ZenLexer

parser.lexer =
  lex: -> [tag, @yytext, @yylineno] = @tokens[@pos++] or [''];tag
  setInput: (@tokens) -> @pos = 0
  upcomingInput: -> ""

parser.yy = require './ZenAST'

# exports.populator = (pops) ->
#   extend POPULATOR_BANK, pops
#
# exports.remove_populator = (pops) ->
#   delete POPULATOR_BANK[pop] for pop in pops
#
# exports.populators = ->
#   POPULATOR_BANK
  
exports.alias = (aliases) ->
  extend ALIAS_BANK, aliases

exports.remove_alias = (aliases) ->
  delete ALIAS_BANK[alias] for alias in aliases
    
exports.aliases = 
  ALIAS_BANK
  
exports.var = (vars) ->
  extend VARIABLE_BANK, vars

exports.remove_var = (vars) ->
  delete VARIABLE_BANK[v] for v of vars
    
