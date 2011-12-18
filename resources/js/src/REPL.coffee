# A very simple Read-Eval-Print-Loop. Compiles one line at a time to JavaScript
# and evaluates it. Good for simple tests, or poking around the **Node.js** API.
# Using it looks like this:
#
#     coffee> console.log "#{num} bottles of beer" for num in [99..1]

# Require the **coffee-script** module to get access to the compiler.
CoffeeScript = require 'coffee-script'
Smack        = require './Smack'
readline     = require 'readline'
colors       = require 'colors'
{inspect}    = require 'util'
{Script}     = require 'vm'
Module       = require 'module'

nonContextGlobals = [
  'Buffer', 'console', 'process'
  'setInterval', 'clearInterval'
  'setTimeout', 'clearTimeout'
  'Smack', 'require'
]

# The sandbox for our repl to run in
sandbox = Script.createContext()

sandbox[g] = global[g] for g in nonContextGlobals
sandbox.global = sandbox.root = sandbox.GLOBAL = sandbox

# Start by opening up `stdin` and `stdout`.
stdin = process.openStdin()
stdout = process.stdout

class SmackREPL
  
  constructor: (@completer) ->
    # Backlog of unused code
    @backlog = ''

    @enableColours = no
    unless process.platform is 'win32'
      @enableColours = not process.env.NODE_DISABLE_COLORS
                
    if readline.createInterface.length < 3
      @repl = readline.createInterface stdin, @completer.complete
      stdin.on 'data', (buffer) -> @repl.write buffer
    else
      @repl = readline.createInterface stdin, stdout, @completer.complete
    
    # Setup events for reply
    @repl.on 'attemptClose', =>
      if @backlog isnt ''
        @backlog = ''
        process.stdout.write '\n'
        @set_prompt()
      else
        @repl.close()

    @repl.on 'close', ->
      process.stdout.write '\n'
      stdin.destroy()

    @repl.on 'line', @run
    
    # Make sure that uncaught exceptions don't kill the REPL.
    process.on 'uncaughtException', error


  begin: -> 
    stdout.write 'Get your Smack on'.red
    @set_prompt mode: 'Smack'
    
  strip_control: (s) ->
    s.replace /\u001b\[[^m]*?m/g, ''
  
  error = (err) ->
    stdout.write (err.stack or err.toString()) + '\n\n'
  
  Smack:
    COLOR: 'green'
    PROMPT: '$mack'.green+' $ '
    PROMPT_CONTINUATION: '$.....>'.green
    RUN: (code) -> 
      console.log Smack.compile code
    CONTINUE_LINE: (code) ->
      @tag_stack = [] unless @tag_stack?
      opens = 0
      close = 0
      i = 0
      
      # code.match 
      
      # while match = /(~:)|(:~)/g.exec code
      #   [match, open_tag, close_tag] = match
      #   opens++ if open_tag?
      #   close++ if close_tag?
      #   i++
      #   break if i > 100
        
      
      # console.log 'opens',opens
      # console.log 'close',close
      # Count open / close tags, stay open until we are matching or have too many close tags
      
      return "#{code[...-1]}\n" if code[code.length - 1] is '\\'
      false
  Coffee:
    COLOR: 'cyan'
    PROMPT: 'coffee'.cyan+' $ '
    PROMPT_CONTINUATION: 'c.....>'.cyan
    CONTINUE_LINE: (code) ->
      return "#{code[...-1]}\n" if code[code.length - 1] is '\\'
      false
    RUN: (code) ->
      _ = sandbox._
      returnValue = CoffeeScript.eval "_=(#{code}\n)", {
        sandbox,
        filename: 'repl'
        modulename: 'repl'
      }
      if returnValue is undefined
        sandbox._ = _
      else
        process.stdout.write inspect(returnValue, no, 2, @enableColours) + '\n'
  Zen:
    COLOR: 'magenta'
    PROMPT: '~ zen ~ '.magenta+' $ '
    PROMPT_CONTINUATION: 'z.....> '.magenta
    RUN: (code) ->
      console.log Smack.Zen.compile code
    CONTINUE_LINE: (code) ->
      return "#{code[...-1]}\n" if code[code.length - 1] is '\\'
      false

  set_prompt: (o = {}) =>
    # if o.mode?
    #   @MODE = @[o.mode]
    #   console.log "Mode: #{o.mode}"
    (@MODE = @[o.mode]; console.log "\nMode: #{o.mode}"[@MODE.COLOR]) if o.mode?
    new_prompt = if o?.continuation then @MODE.PROMPT_CONTINUATION else @MODE.PROMPT
    @repl.setPrompt new_prompt, @strip_control(new_prompt).length
    @repl.prompt()

  # The main REPL function. **run** is called every time a line of code is entered.
  # Attempt to evaluate the command. If there's an exception, print it out instead
  # of exiting.
  run: (buffer) =>

    # Prompt if no code
    if buffer.toString().trim() is '' and @backlog is ''
      set_prompt()
      return

    # Check for :\w 'operators'
    if match = /^:(\w+)/.exec buffer
      [match, op] = match
      @set_prompt mode: 'Smack'  if /^[sS](mack)?$/.test op
      @set_prompt mode: 'Zen'    if /^[zZ](en)?$/.test op 
      @set_prompt mode: 'Coffee' if /^[cC](offee)?$/.test op
      return
      
    # Check if the line is a continuation
    code = @backlog += buffer
    if @MODE.CONTINUE_LINE code
      @backlog = @MODE.CONTINUE_LINE code
      @set_prompt continuation: yes
      return
  
    @backlog = ''
    try
      @MODE.RUN code
    catch err
      error err
    @set_prompt()

class Completer
  
  ACCESSOR: /\s*([\w\.]+)(?:\.(\w*))$/
  SIMPLEVAR: /\s*(\w*)$/i
  std_completions:
    log: 'console.log'
        
  # Returns a list of completions, and the completed text.
  complete = (text) ->
    @std_completion(text) or @completeAttribute(text) or @completeVariable(text) or [[], text]
    
  std_completion = (text) ->
    for k,v of @std_completions
      return [[v], ''] if ///^#{k}///.test text or ///#{k}$///.test text
    if text of @std_completions
      return [[@std_completions[text]], text]

  # Attempt to autocomplete a chained dotted attribute: `one.two.three`.
  completeAttribute = (text) ->
    if match = text.match ACCESSOR
      [all, obj, prefix] = match
      try
        val = Script.runInContext obj, sandbox
      catch error
        return
      completions = @getCompletions prefix, Object.getOwnPropertyNames val
      [completions, prefix]

  # Attempt to autocomplete an in-scope free variable: `one`.
  completeVariable = (text) ->
    free = (text.match @SIMPLEVAR)?[1]
    if free?
      vars = Script.runInContext 'Object.getOwnPropertyNames(this)', sandbox
      keywords = (r for r in CoffeeScript.RESERVED when r[0..1] isnt '__')
      possibilities = vars.concat keywords
      completions = @getCompletions free, possibilities
      [completions, free]    
  
  # Return elements of candidates for which `prefix` is a prefix.
  getCompletions = (prefix, candidates) ->
    el for el in candidates when e
    
new SmackREPL(new Completer).begin()

    
    