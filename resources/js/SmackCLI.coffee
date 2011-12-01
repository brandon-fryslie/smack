CoffeeScript    = require 'coffee-script'
Smack = require './Smack'
helpers        = require './SmackHelpers'
optparse = require './lib/optparse.js'
{EventEmitter} = require 'events'

# Allow Smack to emit Node.js events.
helpers.extend Smack, new EventEmitter

printLine = (line) -> process.stdout.write line + '\n'
printWarn = (line) -> process.binding('stdio').writeError line + '\n'

BANNER = '''
  Usage: smack [options] [path/to/script.smack]
  
  If called without options, `coffee` will read and write from stdin and stdout.
         '''

# The list of all the valid option flags that `coffee` knows how to handle.
SWITCHES = [
  ['-b', '--build',           'build and output SmackCompiler (default: SmackCompiler.js)']
  ['-h', '--help',            'display this help message']
  ['-l', '--lex',             'print out the tokens that the lexer/rewriter produce']
  ['-n', '--nodes',           'print out the parse tree that the parser produces']
  ['-s', '--stdio',           'listen for and compile scripts over stdio']
  ['-v', '--version',         'display the version number']
]

exports.run = ->
  opts = parseOptions()
  return usage()                         if opts.help
  return version()                       if opts.version
  return build()                         if opts.build
  return compileStdio(opts)

parseOptions = ->
  optionParser  = new optparse.OptionParser SWITCHES, BANNER
  o = opts      = optionParser.parse process.argv.slice 2
  o.print       = true
  sources       = o.arguments
  o

# Attach the appropriate listeners to compile scripts incoming over **stdin**,
# and write them back to **stdout**.
compileStdio = (opts) ->
  code = ''
  stdin = process.openStdin()
  stdin.on 'data', (buffer) ->
    code += buffer.toString() if buffer
  stdin.on 'end', ->
    compileScript code, opts

# Compile a single source script, containing the given code, according to the
# requested options. If evaluating the script directly sets `__filename`,
# `__dirname` and `module.filename` to be correct relative to the script's path.
compileScript = (input, o) ->
  try
    t = task = {'', input, o}
    Smack.emit 'compile', task
    if      o.tokens      then printTokens Smack.tokens t.input
    else if o.nodes       then printLine Smack.nodes(t.input).toString().trim()
    else
      t.output = Smack.compile t.input, t.options
      Smack.emit 'success', task
      printLine t.output.trim()
  catch err
    Smack.emit 'failure', err, task
    return if Smack.listeners('failure').length
    printWarn err instanceof Error and err.stack or "ERROR: #{err}"
    process.exit 1

build = ->
  fs = require 'fs'
  
  fs.writeFileSync '../SmackParserC.js', CoffeeScript.run('../SmackParserC.coffee')
  
  files = ['SmackLexer', 'SmackParserC', 'SmackNodes']
  code = {}
  code += CoffeeScript.compile fs.readFileSync("../#{f}.coffee", 'utf8')+'\n' for f in files
  
  code = code.replace 'exports.', 'window.' for f, c in code
    
  fs.writeFileSync '../SmackCompiler.js', code
  console.log "built Smack compiler"

# Pretty-print a stream of tokens.
printTokens = (tokens) ->
  strings = for token in tokens
    [tag, value] = [token[0], token[1].toString().replace(/\n/, '\\n')]
    "[#{tag} #{value}]"
  printLine strings.join(' ')

# Print the `--help` usage message and exit. Deprecated switches are not
# shown.
usage = ->
  printLine (new optparse.OptionParser SWITCHES, BANNER).help()

# Print the `--version` message and exit.
version = ->
  printLine "Smack version #{Smack.VERSION}"
