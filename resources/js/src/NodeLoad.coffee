
fs = require 'fs'
path = require 'path'
CoffeeScript = require 'coffee-script'

require 'jison'

check_parser = ->
  path.exists './Parser.js', (exists) ->
    if exists
      check_zen_parser()
    else
      {parser} = require('./Grammar')
      fs.writeFile './Parser.js', parser.generate(), 'utf8', (err) ->
        throw err if err
        check_zen_parser()
    
check_zen_parser = ->
  path.exists './ZenParser.js', (exists) ->
    if exists
      load_node()
    else
      {zen_parser} = require('./ZenGrammar')
      fs.writeFile './ZenParser.js', zen_parser.generate(), 'utf8', (err) ->
        throw err if err
        load_node()

load_node = ->
  
  sources = [
    'Helper', 'ZenConfig'
    'ZenAST', 'ZenLexer', 'Zen'
    'Lexer', 'AST', 'Smack'
    'Browser'
  ]

  js_sources = [
    'Parser', 'ZenParser'
  ]

  code =  ''  
  for name in js_sources
    code += """
      requires['./#{name}'] = new function() {
        var exports = this;
        #{fs.readFileSync "./#{name}.js", 'utf8'}
      };
    """
  for name in sources
    code += """
      requires['./#{name}'] = new function() {
        var exports = this;
        #{CoffeeScript.compile fs.readFileSync("#{name}.coffee", 'utf8'), bare:yes}
      };
    """
  code = """
    this.Smack = function() {
      requires = {}
      function require(path){ return requires[path] || window[path]; }
      #{code}
      return requires['./Smack'];
    }();
  """
  
  console.info code
  
path.exists './src/Helper.coffee', (exists) ->
  if exists
    process.chdir('./src')
    check_parser()
  else
    check_parser()  
