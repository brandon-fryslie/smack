

# fs = require 'fs'
# path = require 'path'

{Zen}  = (require '../SmackCompiler').Smack
should = require 'should'

console.log()

test = (name, fn) ->
  try
    fn()
  catch err
    console.log 'ERROR\n%s', name
    console.log '%s', err.stack or err or @
    return
  console.log '  √ %s', name


test 'Zen structure', ->
  Zen.should.respondTo 'nodes'
  Zen.should.respondTo 'tokens'
  Zen.should.respondTo 'compile'

test 'Zen Lone Element', ->
  Zen.tokens('p').should.eql([ [ 'ELEMENT', 'p', 1 ] ])
  Zen.tokens('div').should.eql([ [ 'ELEMENT', 'div', 1 ] ])
  Zen.tokens('p').should.not.eql([ [ 'ELEMENT', 'div', 1 ] ])
  Zen.compile('p').should.equal('<p></p>')

test 'Zen Leaves', ->
  Zen.compile('p', leaves: true).should.equal('<p>~|$1|~</p>')
  

test 'Zen El with Abbreviated Attributes', ->
  Zen.tokens('div.alert-message.block-message.info').should.eql([
    [ 'ELEMENT', 'div', 1 ],
    [ 'ATTRIBUTE', { key: '.', value: 'alert-message' }, 1 ],
    [ 'ATTRIBUTE', { key: '.', value: 'block-message' }, 1 ],
    [ 'ATTRIBUTE', { key: '.', value: 'info' }, 1 ] ])
  Zen.compile('div.alert-message.block-message.info').should.equal('<div class="alert-message block-message info"></div>')
  Zen.compile('input#username.input-field+input-form4username=Username::text').should.equal('<input id="username" class="input-field" target="input-form" for="username" value="Username" type="text">')

test 'Zen Operator', ->
  s = 'div > p'
  Zen.tokens(s).should.eql([
    [ 'ELEMENT', 'div', 1 ],
    [ 'ZEN_OPERATOR', '>', 1 ],
    [ 'ELEMENT', 'p', 2 ] ])
  Zen.compile(s).should.eql '<div><p></p></div>'
    
test 'Zen Multiple Operators', ->
  s = 'p > < div + + <<<'
  Zen.tokens(s).should.eql([
    [ 'ELEMENT', 'p', 1 ],
    [ 'ZEN_OPERATOR', '>', 1 ],
    [ 'ZEN_OPERATOR', '<', 2 ],
    [ 'ELEMENT', 'div', 1 ],
    [ 'ZEN_OPERATOR', '+', 1 ],
    [ 'ZEN_OPERATOR', '+', 1 ],
    [ 'ZEN_OPERATOR', '<', 1 ],
    [ 'ZEN_OPERATOR', '<', 0 ],
    [ 'ZEN_OPERATOR', '<', -1 ]])
  
  Zen.compile(s).should.equal '<p></p><div></div>'

test 'Zen Siblings', ->
  Zen.compile('p + div + span + button').should.equal '<p></p><div></div><span></span><button></button>'
  Zen.compile('p div span button').should.equal '<p></p><div></div><span></span><button></button>'

test 'Zen Descendent (>)', ->
  # console.log Zen.nodes('p > p > p > p')
  # console.log 'ZenNodes',Zen.nodes('p > p > p > p').expressions
  Zen.compile('p > div > span > button').should.equal '<p><div><span><button></button></span></div></p>'

test 'Zen Ascendent (<)', ->
  text = """
p > b < p > i
"""
  Zen.compile(text).should.equal('<p><b></b></p><p><i></i></p>')

test 'Zen Root (#)', ->
  text = """
# div 
  > p
    > span
      > i
# div 
  > ul
"""
  Zen.compile(text).should.equal('<div><p><span><i></i></span></p></div><div><ul></ul></div>')

test 'Zen Cleave (!)', ->
  text = """
div 
  > p
    > span
      > i
! div 
  > ul <
"""
  Zen.compile(text).should.equal('<div><p><span><i></i></span></p></div>')

test 'Tag Content', ->
  text = """
ul 
  > li 'Blarney'
  + li 'Stone'
"""
  Zen.compile(text).should.equal('<ul><li>Blarney</li><li>Stone</li></ul>')

console.log
console.log
