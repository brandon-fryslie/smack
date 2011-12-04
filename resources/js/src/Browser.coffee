# Override exported methods for non-Node.js engines.

Smack = require './Smack'
Smack.require = require

# If we're not in a browser environment, we're finished with the public API.
return unless window?

# Compile all the embedded smack tags
compileEmbedded = ->
  scripts = document.getElementsByTagName 'script'
  for s in scripts when s.type is 'text/smack'
    try
      smack_el = document.createElement('div')
      
      smack_el.innerHTML = Smack.compile s.innerHTML
      
      s.parentNode.insertBefore(child, s) for child in smack_el.children
        
      s.parentNode.removeChild s
    catch e
      console.log e
  null

# Bind SmackTag replacement to onload, both in browsers and in IE. <- 
if window.addEventListener
  addEventListener 'DOMContentLoaded', compileEmbedded, no
else
  attachEvent 'onload', compileEmbedded
