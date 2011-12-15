
Smack  = require './Smack'
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

console.log

test 'Smack Embedding', ->
  Smack.tokens('Some Text!').should.eql([ [ 'UNTOUCHABLE', 'Some Text!', 0 ] ])
  Smack.tokens('<h1>Even HTML</h1><small>should remain untouched</small>').should.eql([ [ 'UNTOUCHABLE', '<h1>Even HTML</h1><small>should remain untouched</small>', 0 ] ])

test 'Smack Empty Tag', ->
  text = "~: div.alert-message.block-message.info :~"
  Smack.tokens(text).should.eql([
    [ 'OPENTAG', '~:', 1 ],
    [ 'SMACK_OPERATOR', ' ', 1 ],
    [ 'ZENTAG', 'div.alert-message.block-message.info', 1 ],
    [ 'SMACK_OPERATOR', ' ', 1 ],
    [ 'CLOSETAG', ':~', 1 ] ])
  Smack.compile(text).should.equal('<div class="alert-message block-message info"></div>')
  
test 'Smack Forward Tag', ->
  text = "~:> p >> Yo bro! :~"
  Smack.tokens(text).should.eql([
    [ 'OPENTAG', '~:', 1 ],
    [ 'SMACK_OPERATOR', '>', 1 ],
    [ 'ZENTAG', 'p', 1 ],
    [ 'MIDTAG', '>>', 1 ],
    [ 'LITERAL', 'Yo bro!', 1 ],
    [ 'SMACK_OPERATOR', ' ', 1 ],
    [ 'CLOSETAG', ':~', 1 ] ])
  Smack.compile(text).should.equal('<p>Yo bro!</p>')

test 'Smack Reverse Tag', ->
  text = "~: Yo bro! << p :~"
  Smack.tokens(text).should.eql([
    [ 'OPENTAG', '~:', 1 ],
    [ 'SMACK_OPERATOR', ' ', 1 ],
    [ 'LITERAL', 'Yo bro!', 1 ],
    [ 'MIDTAG', '<<', 1 ],
    [ 'ZENTAG', 'p', 1 ],
    [ 'SMACK_OPERATOR', ' ', 1 ],
    [ 'CLOSETAG', ':~', 1 ] ])
  Smack.compile(text).should.equal('<p>Yo bro!</p>')
  # Smack.tokens('div').should.eql([ [ 'ELEMENT', 'div' ] ])
  # Smack.tokens('p').should.not.eql([ [ 'ELEMENT', 'div' ] ])
  # Smack.compile('p').should.equal('<p></p>')
  # Smack.compile('p', leaves: true).should.equal('<p>~:$1:~</p>')

test 'Smack Split Tag', ->
  text = """
~:split |> p + p + p + p >>
Whoa | Bro | Low | Blow!
:~
~:split |> p > p > p > p >>
Whoa Bro Low Blow!
:~
"""
  Smack.compile(text).should.equal("""
<p>Whoa</p><p>Bro</p><p>Low</p><p>Blow!</p>
<p><p><p><p>Whoa Bro Low Blow!</p></p></p></p>
""")

test 'Smack Site HTML', ->
  text = """
~: cuz life is too short to be writing HTML << h1 > small :~
"""
  Smack.compile(text).should.equal('<h1><small>cuz life is too short to be writing HTML</small></h1>')

test 'Smack Bootstrap Topbar', ->
  text = """
~:
div.topbar
  > div.fill
    > div.container-fluid
      > 'RV' a.brand:#
      + ul.nav&tabs:tabs
        > li.active 
          > 'Recruitment Viewer' a:#viewer-tab <
        + li.dropdown&dropdown:dropdown
          > 'Documentation' a.dropdown-toggle:#doc-tab
          + ul.dropdown-menu
            > 'Gene Annotation' li > a(+)doc-iframe:resources/docs/1_gene_annotation.html <
            + 'HPC'             li > a(+)doc-iframe:resources/docs/2_HPC.html             <
            + 'Blast'           li > a(+)doc-iframe:resources/docs/3_Blast.html           <
            + 'Newbler'         li > a(+)doc-iframe:resources/docs/4_Newbler.html         <
:~"""

  Smack.compile(text).should.equal '<div class="topbar"><div class="fill"><div class="container-fluid"><a class="brand" href="#">RV</a><ul class="nav" data-tabs="tabs"><li class="active"><a href="#viewer-tab">Recruitment Viewer</a></li><li class="dropdown" data-dropdown="dropdown"><a class="dropdown-toggle" href="#doc-tab">Documentation</a><ul class="dropdown-menu"><li><a target="doc-iframe" href="resources/docs/1_gene_annotation.html"></a></li><li><a target="doc-iframe" href="resources/docs/2_HPC.html"></a></li><li><a target="doc-iframe" href="resources/docs/3_Blast.html"></a></li><li><a target="doc-iframe" href="resources/docs/4_Newbler.html"></a></li></ul></li></ul></div></div></div>'

test 'Smack Recursive', ->
  text = """
~:> div >>
  ~: p b i :~
  ~: ul
    > li 'Stuff'
      li 'Goes'
      li 'In'
      li 'Here'
  :~
:~
"""

  nodes = Smack.nodes text
  Smack.compile(text).should.equal '<div><p></p><b></b><i></i><ul><li>Stuff</li><li>Goes</li><li>In</li><li>Here</li></ul></div>'

console.log
console.log
