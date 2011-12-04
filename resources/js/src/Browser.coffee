# Override exported methods for non-Node.js engines.

Smack = require './Smack'
Smack.require = require

# Use standard JavaScript `eval` to eval code.
Smack.eval = (code, options) ->
  eval Smack.compile code, options

# Running code does not provide access to this scope.
Smack.run = (code, options = {}) ->
  options.bare = on
  Function(Smack.compile code, options)()

# If we're not in a browser environment, we're finished with the public API.
return unless window?

# Load a remote script from the current domain via XHR.
Smack.load = (url, callback) ->
  xhr = new (window.ActiveXObject or XMLHttpRequest)('Microsoft.XMLHTTP')
  xhr.open 'GET', url, true
  xhr.overrideMimeType 'text/plain' if 'overrideMimeType' of xhr
  xhr.onreadystatechange = ->
    if xhr.readyState is 4
      if xhr.status in [0, 200]
        Smack.run xhr.responseText
      else
        throw new Error "Could not load #{url}"
      callback() if callback
  xhr.send null

# Activate Smack in the browser by having it compile and evaluate
# all script tags with a content-type of `text/Smack`.
# This happens on page load.
runScripts = ->
  scripts = document.getElementsByTagName 'script'
  smack_blocks = (s for s in scripts when s.type is 'text/smack')
  index = 0
  length = smack_blocks.length
  do execute = ->
    script = smack_blocks[index++]
    if script?.type is 'text/Smack'
      if script.src
        Smack.load script.src, execute
      else
        Smack.run script.innerHTML
        execute()
  null

# Listen for window load, both in browsers and in IE.
if window.addEventListener
  addEventListener 'DOMContentLoaded', runScripts, no
else
  attachEvent 'onload', runScripts
