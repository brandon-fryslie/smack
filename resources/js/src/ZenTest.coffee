

# fs = require 'fs'
# path = require 'path'

Zen  = require './Zen'
{DEFAULT_ATTRIBUTES} = require './ZenAST'

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
  Zen.compile('p', leaves: true).should.equal('<p>~:$1:~</p>')
  

test 'Zen El with Abbreviated Attributes', ->
  Zen.tokens('div.alert-message.block-message.info').should.eql([
    [ 'ELEMENT', 'div', 1 ],
    [ 'ATTRIBUTE', { key: '.', value: 'alert-message' }, 1 ],
    [ 'ATTRIBUTE', { key: '.', value: 'block-message' }, 1 ],
    [ 'ATTRIBUTE', { key: '.', value: 'info' }, 1 ] ])
  Zen.compile('div.alert-message.block-message.info').should.equal('<div class="alert-message block-message info"></div>')
  Zen.compile('input#username.input-field(4)username(+)input-form(=)Username').should.equal('<input id="username" class="input-field" type="text" for="username" target="input-form" value="Username">')
  Zen.compile('form(+)http://www.google.com:http://www.microsoft.com').should.equal('<form target="http://www.google.com" action="http://www.microsoft.com"></form>')

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

test 'Tag Content String', ->
  text = """
ul
  > li 'Blarney'
  + li 'Stone'
"""
  Zen.compile(text).should.equal('<ul><li>Blarney</li><li>Stone</li></ul>')

test 'Tag Content Variable', ->
  Zen.var blarney: 'Hey Yo', stone: "Let's get stoned!"
  text = """
ul
  > li $blarney
  + li $stone
"""
  Zen.compile(text).should.equal('<ul><li>Hey Yo</li><li>Let\'s get stoned!</li></ul>')

test 'Default Attributes', ->
  Zen.compile('img input').should.equal('<img alt=""><input type="text">')
  Zen.compile('iframe').should.equal('<iframe style="border:0;width:0px;height:0px"></iframe>')

test 'Primary Attributes', ->
  Zen.compile("""
a:google.com
script:yahoo.com/query.js
img:pic.jpg
link:bootstrap.css
input:Username
form:web.cgi""").should.equal("""<a href="google.com"></a><script src="yahoo.com/query.js"></script><img alt="" src="pic.jpg"><link rel="stylesheet" href="bootstrap.css"><input type="text" value="Username"><form action="web.cgi"></form>""")

test 'Shorthand Attributes', ->
  Zen.compile('meta(rel)start').should.equal('<meta rel="start">')

test 'Zen Alias', ->
  Zen.compile('@topbar(RV) # div.clearfix').should.equal('<div class="topbar"><div class="fill"><div class="container-fluid"><a class="brand" href="#">RV</a></div></div></div><div class="clearfix"></div>')


console.log
console.log
