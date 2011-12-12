
{Smack}  = require '../SmackCompiler'
c = Smack.compile
t = Smack.tokens

should = require 'should'

test = (name, fn) ->
  try
    fn()
  catch err
    console.log 'ERROR\n%s', name
    console.log '%s', err.stack
    return
  console.log '  √ %s', name

easy1 = "~|> p >> Yo bro! |~"
easy2 = "~| Yo bro! << p |~"
easy3 = "~| p |~"

console.log

test 'Smack Embedding', ->
  Smack.tokens('Some Text!').should.eql([ [ 'LITERAL', 'Some Text!' ] ])
  Smack.tokens('<h1>Even HTML</h1><small>should remain untouched</small>').should.eql([ [ 'LITERAL', '<h1>Even HTML</h1><small>should remain untouched</small>' ] ])

test 'Smack Empty Tag', ->
  text = "~| div.alert-message.block-message.info |~"
  Smack.tokens(text).should.eql([
    [ 'OPENTAG', '~|' ],
    [ 'SMACK_OPERATOR', ' ' ],
    [ 'ZENTAG', 'div.alert-message.block-message.info' ],
    [ 'SMACK_OPERATOR', ' ' ],
    [ 'CLOSETAG', '|~' ] ])
  Smack.compile(text).should.equal('<div class="alert-message block-message info"></div>')
  
test 'Smack Forward Tag', ->
  text = "~|> p >> Yo bro! |~"
  Smack.tokens(text).should.eql([
    [ 'OPENTAG', '~|' ],
    [ 'SMACK_OPERATOR', '>' ],
    [ 'ZENTAG', 'p' ],
    [ 'MIDTAG', '>>' ],
    [ 'LITERAL', 'Yo bro!' ],
    [ 'SMACK_OPERATOR', ' ' ],
    [ 'CLOSETAG', '|~' ] ])
  Smack.compile(text).should.equal('<p>Yo bro!</p>')

test 'Smack Reverse Tag', ->
  text = "~| Yo bro! << p |~"
  Smack.tokens(text).should.eql([
    [ 'OPENTAG', '~|' ],
    [ 'SMACK_OPERATOR', ' ' ],
    [ 'LITERAL', 'Yo bro!' ],
    [ 'MIDTAG', '<<' ],
    [ 'ZENTAG', 'p' ],
    [ 'SMACK_OPERATOR', ' ' ],
    [ 'CLOSETAG', '|~' ] ])
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
  
  Smack.compile(text).should.equal('<p>Whoa</p><p>Bro</p><p>Low</p><p>Blow!</p><p><p><p><p>Whoa Bro Low Blow!</p></p></p></p>')

test 'Smack Site HTML', ->
  text = """
~| cuz life is too short to be writing HTML << h1 > small |~
"""
  Smack.compile(text).should.equal('<h1><small>cuz life is too short to be writing HTML</small></h1>')
  

console.log
console.log

# easy1_c = c easy3
# console.log c easy2
# console.log c easy3
# console.log t easy1
# console.log t easy2
# console.log t easy3

aliases = """
~| username << fieldset > @bs.input_box > input#username::text 'name: username' |~
"""

operators = """
~|split ///> p > div $cat + span $dog
>>
  This /// is /// a /// split /// tag
|~
"""
# console.log c operators


# ok Smack.compile """
#     Any other text
#           <h1>Like other html</h1>
# or {{"Mustcache"}} should be able to be here
#
#           untouched
#
#   ~|>
#     p#status.block-message 'alt: Bla Bla Bla' > div.clear-fix
#   >>
#     Upload Successful!
#   |~
#
#   And afterwards too
# """, """
#   Any other text
#         <h1>Like other html</h1>
# or {{"Mustcache"}} should be able to be here
#
#         untouched
#
# <p id="status" class="block-message" alt="Bla Bla Bla"><div class="clear-fix"></div></p>
#
# And afterwards too
# """
# equal c("~| Yo bro! << p |~"), "<p>Yo bro!</p>"

# equal c("~|> p >> Low blow! |~"), "<p>Low blow!</p>"

# equal c("~|split |> p + p >> Hey! | Ho! |~"), "<p>Hey!</p><p>Ho!</p>"

# equal c("~|split |> p + p >> Hey! | Ho! |~"), "<p>Hey!</p><p>Ho!</p>"

# ok c("""
# ~|>
#   form 'action: web.cgi' >
#     fieldset >
#       div.clearfix > label4username + div.input > input#username::text 'name: username'
# >>
#
# username password
#
# |~
# """), """
# <form action="web.cgi">
#   <fieldset>
#     <div class="clearfix">
#       <label for="username">username</label>
#       <div class="input">
#         <input id="username" name="username" type="text">
#       </div>
#     </div>
#     <div class="clearfix">
#       <label for="password">password</label>
#       <div class="input">
#         <input id="password" name="password" type="text">
#       </div>
#     </div>
#   </fieldset>
#   <div class="actions">
#     <input type="submit" name="action" value="login" class="btn primary">
#   </div>
# </form>
# """



s1 = """
~|>
  form 'action: web.cgi'
    > fieldset
      > div.clearfix
        > label4username
        + div.input
          > input#username::text 'name: username'
      < div.clearfix
        > label4password
        + div.input
          > input#password::password 'name: password'
    < div.actions
      input.btn.primary::submit=login 'name: action'
>>

username

|~
"""

s1 = """
~|split />
  div.a
    > div.one
    > div.two
< div.b
    > div.three
    > div.four
>>
one / two / three / four
|~
"""

# console.log c s1

# console.log "s1: ", c("~|> p >> Low blow! |~")

s2 = """
  ~| You have Success!!! << div.clear-fix >
                          p#status.error.block-message
                          'alt: Bla Bla Bla, target: #other-places, action: web.cgi' |~
"""

s3 = """
~| Check this out! << div+balls=HeyHey::facist > a&controls-modal:option-panel |~
"""

empty_tags = """
~| label4grammar-input > textarea#grammar-input.expando |~
"""

sibling_zen_op = """

~|> div#grammar-options.active > h5 + label4grammar-input + textarea#grammar-input + label4grammar-input
    + p#grammar-input + div#delimiter + span#rule-delimiter::text >>
Input&nbsp;Grammar /// Grammar /// /// Rule Delimiter /// Empty string ///
Terminal Regex /// Variable regex /// Start Variable

|~
"""

sibling_zen_op2 = """

~|> div#grammar-options.active > h5 + label4grammar-input >>


|~
"""

# Operators
#
# [ ] (space) - reverse tag, get smack operator from rear tag
#
# >
# end of smack operators, begin output
#
# split <string>
# splits the output by string and applies one piece to each leaf
#

operators = """
~|split ///> p + p + p + p + p >>
  This /// is /// a /// split /// tag
|~

            
"""


# console.log Smack.compile operators
