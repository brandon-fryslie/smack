CoffeeScript = require('coffee-script')
Smack  = require './Smack'
fs = require 'fs'
path = require 'path'

# Arguments
args = process.argv.splice(2)

for arg in args
  switch arg
    when '-nohtml' then display_html = no

display_html ?= yes

font_properties =
  bold: 'weight'
  italics: 'weight'

# Log a message with a style.
log = (message, style, explanation) ->
  style = if style in font_properties 
    "font-#{font_properties[style]}:#{style};"
  else
    "color:#{style};"
  if display_html
    console.log """<span style="#{style}">#{message}</span> #{(explanation or '')}"""
  else
    console.log message
  


# Run the Smack test suite.
exports.runTests = (Smack) ->
    
  startTime   = Date.now()
  currentFile = null
  passedTests = 0
  failures    = []

  # Make "global" reference available to tests
  global.global = global

  # Mix in the assert module globally, to make it available for tests.
  addGlobal = (name, func) ->
    global[name] = ->
      passedTests += 1
      func arguments...

  addGlobal name, func for name, func of require 'assert'

  # Convenience aliases.
  global.eq = global.strictEqual
  global.Smack = Smack

  # Our test helper function for delimiting different test cases.
  global.test = (description, fn) ->
    try
      fn.test = {description, currentFile}
      fn.call(fn)
    catch e
      e.description = description if description?
      e.source      = fn.toString() if fn.toString?
      failures.push filename: currentFile, error: e

  # A recursive functional equivalence helper; uses egal for testing equivalence.
  # See http://wiki.ecmascript.org/doku.php?id=harmony:egal
  arrayEqual = (a, b) ->
    if a is b
      # 0 isnt -0
      a isnt 0 or 1/a is 1/b
    else if a instanceof Array and b instanceof Array
      return no unless a.length is b.length
      return no for el, idx in a when not arrayEqual el, b[idx]
      yes
    else
      # NaN is NaN
      a isnt a and b isnt b

  global.arrayEq = (a, b, msg) -> ok arrayEqual(a,b), msg

  # When all the tests have run, collect and print errors.
  # If a stacktrace is available, output the compiled function source.
  process.on 'exit', ->
    time = ((Date.now() - startTime) / 1000).toFixed(2)
    message = "passed #{passedTests} tests in #{time} seconds"
    return log(message, 'green') unless failures.length
    log "failed #{failures.length} and #{message}", 'red'
    for fail in failures
      {error, filename}  = fail
      match              = error.stack?.match(new RegExp(fail.file+":(\\d+):(\\d+)"))
      match              = error.stack?.match(/on line (\d+):/) unless match
      [match, line, col] = match if match
      console.log ''
      log "  #{error.description}", 'red' if error.description
      log "  #{error.stack || error}", 'red'
      log "  #{filename}: line #{line ? 'unknown'}, column #{col ? 'unknown'}", 'red'
      console.log "  #{error.source}" if error.source
    return

  # Run every test in the `test` folder, recording failures.
  test_path = '/Library/WebServer/Documents/smack/resources/js/test'
  files = fs.readdirSync test_path
  for file in files when file.match /\.coffee$/i
    currentFile = filename = path.join test_path, file
    code = fs.readFileSync filename, 'utf8'
    # {smack, html} = eval fs.readFileSync filename
    try
      for test in code.split '***'
        if match = ///^[\s\S]*Smack:\s*([\s\S]*?)\s*HTML:\s*([\s\S]*?)\s*$///.exec test 
          smack = Smack.compile(match[1])
          if smack != match[2] 
            console.log typeof smack
            console.log typeof match[2]
            throw "\nError:\n***\n#{smack}\n***\n is not equal to \n***\n#{match[2]}\n***\n"
    catch error
      failures.push {filename, error}
  return !failures.length

    # test_strings = [
  #     # '~| p#status.block-message~ Upload Successful! |~'
  #     # '~| Upload Successful! ~p#status.block-message |~'
  #     '~|
  #       p#status.block-message |alt:Bla Bla Bla| > div.clear-fix~
  # 
  #       Upload Successful!
  #     |~'
  #     "~| Upload Successful! ~p#status.block-message |alt:Bla Bla Bla| > div.clear-fix |~"
  #   ]
exports.runTests Smack