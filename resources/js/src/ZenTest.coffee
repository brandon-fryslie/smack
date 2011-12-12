

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
    console.log '%s', err.stack
    return
  console.log '  √ %s', name


test 'Zen structure', ->
  Zen.should.respondTo 'nodes'
  Zen.should.respondTo 'tokens'
  Zen.should.respondTo 'compile'

test 'Zen Lone Element', ->
  Zen.tokens('p').should.eql([ [ 'ELEMENT', 'p' ] ])
  Zen.tokens('div').should.eql([ [ 'ELEMENT', 'div' ] ])
  Zen.tokens('p').should.not.eql([ [ 'ELEMENT', 'div' ] ])
  Zen.compile('p').should.equal('<p></p>')
  Zen.compile('p', leaves: true).should.equal('<p>~|$1|~</p>')

test 'Zen Leaves', ->
  # console.log 'ZenCompile', Zen.compile('p + p + p')
  # console.log 'ZenCompile', Zen.compile('p > p > p')
  # console.log 'ZenLeaves', Zen.leaves('p + p + p')
  # console.log 'ZenLeaves', Zen.leaves('p > p > p')

test 'Zen El with Abbreviated Attributes', ->
  Zen.tokens('div.alert-message.block-message.info').should.eql([ 
    [ 'ELEMENT', 'div' ],
    [ 'ABBREVIATED_ATTRIBUTE', { key: '.', value: 'alert-message' } ],
    [ 'ABBREVIATED_ATTRIBUTE', { key: '.', value: 'block-message' } ],
    [ 'ABBREVIATED_ATTRIBUTE', { key: '.', value: 'info' } ] ])
  Zen.compile('div.alert-message.block-message.info').should.equal('<div class="alert-message block-message info"></div>')
  Zen.compile('input#username.input-field+input-form4username=Username::text').should.equal('<input id="username" class="input-field" target="input-form" for="username" value="Username" type="text">')

test 'Zen Siblings', ->
  Zen.compile('p + p + p + p').should.equal '<p></p><p></p><p></p><p></p>'

test 'Zen Descendent', ->
  # console.log Zen.nodes('p > p > p > p')
  # console.log 'ZenNodes',Zen.nodes('p > p > p > p').expressions
  Zen.compile('p > p > p > p').should.equal '<p><p><p><p></p></p></p></p>'

console.log
console.log


# console.log 'ZenTest: ZenTokens p + p + p + p', Zen.compile('p + p + p + p')
# console.log 'ZenTest: ZenCompile div.alert-message.block-message.info', Zen.tokens('input#username.input-field+input-form4username=Username::text')



singleton = 'input'

zentag = """
div#grammar-options.active > h5 + label4grammar-input
"""

zentag = """
div#grammar-options.active > h5 + label4grammar-input
"""

# console.log Zen.compile zentag
