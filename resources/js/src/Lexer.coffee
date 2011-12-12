
{peek, trim} = require './Helper'

exports.Lexer = class Lexer
  
  TEST:
    MAIN: 0
    OPENTAG: 0
    WHITESPACE: 0
    FOR_TOKENS: 0
    ELEMENT: 0
    LITERAL: 0
    
  tokenize: (code) ->
        
    @code = code.replace(/\r/g, '')
    @line = 0
    @tokens = []
    @configuration_stack = []
    
    i = 0
    while @chunk = @code.slice i

      i +=  @OpenTag() or
            @Midtag() or
            @CloseTag() or
            @ZenTag() or
            @Literal() or
            @Whitespace() or
            @LexerError()
    return @tokens
  
  last: (array, back) ->
    array[array.length - (back or 0) - 1]

  tag: (index, tag) ->
    (tok = @last @tokens, index) and if tag then tok[0] = tag else tok[0]
  
  value: (index, val) ->
    (tok = @last @tokens, index) and if val then tok[1] = val else tok[1]

  type: ->
    peek(@configuration_stack)?.type

  check_status: ->
    "Type"  : @type()
    "chunk" : @chunk

  OpenTag: ->
    return 0 unless match = OpenTagRE.exec @chunk
    [match, tag, op] = match
        
    @tokens.push [ 'OPENTAG', tag ]
    
    @tokens.push [ 'SMACK_OPERATOR', op ]
    
    throw 'Lexer: Missing Smack Operator (Open)' if @tag() isnt 'SMACK_OPERATOR'
    
    if @value() isnt ' '
      type = 'REGULAR'
    else if (CloseTagTest.exec(@chunk)?.index ? @chunk.length) < (MidtagTest.exec(@chunk)?.index ? @chunk.length)
      type = 'EMPTY'
    else
      type = 'REVERSE'
    
    @configuration_stack.push type: type
    
    match.length
  
  Midtag: ->
    return 0 unless match = MidtagRE.exec(@chunk)
    [match, tag] = match
    @tokens.push [ 'MIDTAG', tag ]
    match.length
  
  CloseTag: ->
    return 0 unless match = CloseTagRE.exec(@chunk)
      
    [match, op, tag] = match
    
    @tokens.push [ 'SMACK_OPERATOR', op ]
      
    @tokens.push [ 'CLOSETAG', tag ]
    
    match.length
  
  SmackVariable: ->
    return 0 unless match = SmackVariableRE.exec @chunk
    [match, tag, op] = match
    console.log 'smackvar' if @TEST?.SMACKVAR
    @tokens.push [ 'SMACK_VARIABLE', match ]
    match.length    
  
  ZenTag: ->
    return 0 if @configuration_stack.length is 0
    return 0 if @type() is 'REGULAR' and @tag() isnt 'SMACK_OPERATOR'
    return 0 if @type() is 'REVERSE' and @tag() isnt 'MIDTAG'
    
    if @type() is 'REGULAR' and @tag() is 'SMACK_OPERATOR'
      close_idx = MidtagTest.exec(@chunk)?.index
    else if @type() is 'REVERSE' and @tag() is 'MIDTAG'
      close_idx = CloseTagTest.exec(@chunk)?.index
    else if @type() is 'EMPTY' and @tag() is 'SMACK_OPERATOR'
      close_idx = CloseTagTest.exec(@chunk)?.index
      
    throw "No closing MIDTAG or CLOSE_TAG for ZENTAG" unless close_idx?
    
    zentag = @chunk[0...close_idx]
    
    @tokens.push [ 'ZENTAG', trim(zentag) ]
    close_idx
  
  # Literal text
  # Any characters not in a smack tag or variable
  Literal: ->
    
    # If we aren't in a tag, it is a literal for sure
    return if @configuration_stack.length is 0
      open_idx = OpenTagTest.exec(@chunk)?.index ? @chunk.length
      @tokens.push [ 'LITERAL', @chunk[...open_idx] ]
      open_idx
    
    return 0 if @type() is 'REGULAR' and @tag() isnt 'MIDTAG'
    return 0 if @type() is 'REVERSE' and @tag() isnt 'SMACK_OPERATOR'
    
    close_idx = if @type() is 'REGULAR' and @tag() is 'MIDTAG'
      CloseTagTest.exec(@chunk)?.index
    else if @type() is 'REVERSE' and @tag() is 'SMACK_OPERATOR'
      MidtagTest.exec(@chunk)?.index
    
    unless close_idx?
      console.log "Warning, inside tag and no midtag/closetag found..." 
      console.log "@tag(): ", @tag()
      console.log "@value(): ", @value()
      console.log "@type(): ", @type()
      console.log "@chunk(): ", @chunk

    # Implement recursion here. later
    # open_idx = OpenTagTest.exec(@chunk)?.index ? @chunk.length
    
    literal = @chunk[0...close_idx]

    # Push token after trimming whitespace
    @tokens.push [ 'LITERAL', literal.replace(/^\s\s*/, '').replace(/\s\s*$/, '') ]

    literal.length
    
  Whitespace: ->
    return 0 unless match = Whitespace.exec @chunk
    return match[0].length
  
  LexerError: ->
    try
      throw null
    catch e
      console.log '--- ERRROR ---'
      console.log "Not a token: #{@chunk}"
      console.log '@tokens'
      console.log @tokens
      console.log @check_status()
      throw "Fix your lexers"
    tok = @chunk[0]
    @tokens.push [ 'TOKEN', tok ]
    tok.length

OpenTagRE    = /^(~[|])(\s|[^<>]*?>)/
OpenTagTest  =  /(~[|])(\s|[^<>]*?>)/
CloseTagRE   = /^(<[^<>]*?|\s)([|]~)/
CloseTagTest =  /(<[^<>]*?|\s)([|]~)/

MidtagRE   = /^(>>|<<)/
MidtagTest =  /(>>|<<)/

SmackVariableRE = /$([a-zA-Z0-9_$]+)|${?([a-zA-Z0-9_$\[\].]+)}/

# Zen Populator is a JS object to use in your template
# Can also reference some global and preset values (think Ruby)
# It's a JS identifier with a $ at the beginning
# Token matching regexes.

# Snatched from CoffeeScript
Identifier = /([$A-Za-z_\x7f-\uffff][$\w\x7f-\uffff]*)/
ZenPopulator = ///^\$([$A-Za-z_\x7f-\uffff][$\.\w\x7f-\uffff]*)///
ZenAlias = /^@[a-zA-Z0-9\-_\.]+/

Number = ///
  ^ 0x[\da-f]+ |              # hex
  ^ \d*\.?\d+ (?:e[+-]?\d+)?  # decimal
///i

Whitespace = /^\s+/
