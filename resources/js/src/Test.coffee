
{Smack}  = require '../SmackCompiler'
c = Smack.compile
t = Smack.tokens

should = require 'should'

test = (name, fn) ->
  try
    fn()
  catch err
    console.log 'ERROR\n%s', name
    console.log err.stack or err
    return
  console.log '  √ %s', name

easy1 = "~|> p >> Yo bro! |~"
easy2 = "~| Yo bro! << p |~"
easy3 = "~| p |~"

console.log

test 'Smack Embedding', ->
  Smack.tokens('Some Text!').should.eql([ [ 'UNTOUCHABLE', 'Some Text!', 0 ] ])
  Smack.tokens('<h1>Even HTML</h1><small>should remain untouched</small>').should.eql([ [ 'UNTOUCHABLE', '<h1>Even HTML</h1><small>should remain untouched</small>', 0 ] ])

test 'Smack Empty Tag', ->
  text = "~| div.alert-message.block-message.info |~"
  Smack.tokens(text).should.eql([
    [ 'OPENTAG', '~|', 1 ],
    [ 'SMACK_OPERATOR', ' ', 1 ],
    [ 'ZENTAG', 'div.alert-message.block-message.info', 1 ],
    [ 'SMACK_OPERATOR', ' ', 1 ],
    [ 'CLOSETAG', '|~', 1 ] ])
  Smack.compile(text).should.equal('<div class="alert-message block-message info"></div>')
  
test 'Smack Forward Tag', ->
  text = "~|> p >> Yo bro! |~"
  Smack.tokens(text).should.eql([
    [ 'OPENTAG', '~|', 1 ],
    [ 'SMACK_OPERATOR', '>', 1 ],
    [ 'ZENTAG', 'p', 1 ],
    [ 'MIDTAG', '>>', 1 ],
    [ 'LITERAL', 'Yo bro!', 1 ],
    [ 'SMACK_OPERATOR', ' ', 1 ],
    [ 'CLOSETAG', '|~', 1 ] ])
  Smack.compile(text).should.equal('<p>Yo bro!</p>')

test 'Smack Reverse Tag', ->
  text = "~| Yo bro! << p |~"
  Smack.tokens(text).should.eql([
    [ 'OPENTAG', '~|', 1 ],
    [ 'SMACK_OPERATOR', ' ', 1 ],
    [ 'LITERAL', 'Yo bro!', 1 ],
    [ 'MIDTAG', '<<', 1 ],
    [ 'ZENTAG', 'p', 1 ],
    [ 'SMACK_OPERATOR', ' ', 1 ],
    [ 'CLOSETAG', '|~', 1 ] ])
  Smack.compile(text).should.equal('<p>Yo bro!</p>')
  # Smack.tokens('div').should.eql([ [ 'ELEMENT', 'div' ] ])
  # Smack.tokens('p').should.not.eql([ [ 'ELEMENT', 'div' ] ])
  # Smack.compile('p').should.equal('<p></p>')
  # Smack.compile('p', leaves: true).should.equal('<p>~|$1|~</p>')

test 'Smack Split Tag', ->
  text = """
~|split |> p + p + p + p >>
Whoa | Bro | Low | Blow!
|~
~|split |> p > p > p > p >>
Whoa Bro Low Blow!
|~
"""
  Smack.compile(text).should.equal("""
<p>Whoa</p><p>Bro</p><p>Low</p><p>Blow!</p>
<p><p><p><p>Whoa Bro Low Blow!</p></p></p></p>
""")

test 'Smack Site HTML', ->
  text = """
~| cuz life is too short to be writing HTML << h1 > small |~
"""
  Smack.compile(text).should.equal('<h1><small>cuz life is too short to be writing HTML</small></h1>')

test 'Smack Bootstrap Topbar', ->
  text = """
  
~|
div.topbar
  > div.fill
    > div.container-fluid
      > a.brand |href: #| 'RV'
      + ul.nav |data-tabs: tabs|
        > li.active > a |href: #viewer-tab| <
        + li.dropdown |data-dropdown: dropdown|
          > a.dropdown-toggle |href: #doc-tab|
          + ul.dropdown-menu
            > li > a+doc-iframe |href: resources/docs/1_gene_annotation.html| <
            + li > a+doc-iframe |href: resources/docs/2_HPC.html| <
            + li > a+doc-iframe |href: resources/docs/3_Blast.html| <
            + li > a+doc-iframe |href: resources/docs/4_Newbler.html| <
|~

"""
  # Smack.compile(text).should.equal '<div></div>'

test 'Smack Recursive', ->
  text = """
~|> div >>
  ~| p b i |~
  ~| ul
    > li 'Stuff'
      li 'Goes'
      li 'In'
      li 'Here'
  |~
|~
"""

  nodes = Smack.nodes text
  Smack.compile(text).should.equal '<div><p></p><b></b><i></i><ul><li>Stuff</li><li>Goes</li><li>In</li><li>Here</li></ul></div>'

console.log
console.log
