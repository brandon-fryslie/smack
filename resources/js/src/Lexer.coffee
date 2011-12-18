
{peek, trim, count} = require './Helper'

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
            @Unknown()
    return @tokens

  toke: (tag, value) ->
    @tokens.push [tag, value, @line]
  
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
    
    @toke 'OPENTAG', tag
    @toke 'SMACK_OPERATOR', op

    @line += count op
    chunk = @chunk[match.length...]
    
    if not /^\s$/.test @value()
      type = 'REGULAR'
    else if (CloseTagTest.exec(chunk)?.index ? chunk.length) < (MidtagTest.exec(chunk)?.index ? chunk.length)    
      type = 'EMPTY'
    else
      type = 'REVERSE'

    @configuration_stack.push type: type

    match.length
  
  Midtag: ->
    return 0 unless match = MidtagRE.exec(@chunk)
    [match, tag] = match
    @toke 'MIDTAG', tag
    match.length
  
  CloseTag: ->
    return 0 unless match = CloseTagRE.exec(@chunk)
      
    [match, op, tag] = match
    
    @toke 'SMACK_OPERATOR', op
    @toke 'CLOSETAG', tag
    
    @line += count op
    @configuration_stack.pop()
    
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
      
    throw {msg: "No closing MIDTAG or CLOSE_TAG for ZENTAG", chunk: @chunk, tokens: @tokens} unless close_idx?
    zentag = @chunk[0...close_idx]
    
    @toke 'ZENTAG', trim(zentag)
    close_idx
  
  # Literal text
  # Any characters not in a smack tag or variable
  Literal: ->
    
    # If we aren't in a tag, it is a literal for sure
    return if @configuration_stack.length is 0
      open_idx = OpenTagTest.exec(@chunk)?.index ? @chunk.length
      @toke 'UNTOUCHABLE', @chunk[...open_idx]
      open_idx
    
    return 0 if @type() is 'EMPTY'
    return 0 if @type() is 'REGULAR' and @tag() isnt 'MIDTAG'
    return 0 if @type() is 'REVERSE' and @tag() isnt 'SMACK_OPERATOR'
    
    open_tag_idx = OpenTagTest.exec(@chunk)?.index

    if @type() is 'REGULAR' and @tag() is 'MIDTAG'
      end_idx = CloseTagTest.exec(@chunk)?.index
    else if @type() is 'REVERSE' and @tag() is 'SMACK_OPERATOR'
      end_idx = MidtagTest.exec(@chunk)?.index
    
    # Is this a nested tag?
    end_idx = open_tag_idx if open_tag_idx < end_idx 
    
    # unless end_idx?
    #   console.log "Warning, inside tag and no midtag/closetag found..." 
    #   console.log "@tag(): ", @tag()
    #   console.log "@value(): ", @value()
    #   console.log "@type(): ", @type()
    #   console.log "@chunk(): ", @chunk

    
    literal = @chunk[0...end_idx]
    
    to_push = []
    
    # Parse the literal for variables
    while match = SmackVariable.exec literal
      console.log match

    # Push token after trimming whitespace
    @toke 'LITERAL', trim literal

    literal.length
    
  Whitespace: ->
    return 0 unless match = Whitespace.exec @chunk
    return match[0].length
  
  Unknown: ->
    if @tag() is 'UNKNOWN'
      [tag, value] = @tokens.pop()
      @toke value+@chunk[0]
      return value.length+1
    @toke @chunk[0]
    1

OpenTagRE    = /^(~:)(\s|[^:]*?:)/
OpenTagTest  =  /(~:)(\s|[^:]*?:)/
CloseTagRE   = /^(\s|:[^:]*?)(:~)/
CloseTagTest =  /(\s|:[^:]*?)(:~)/

MidtagRE   = /^(>>|<<)/
MidtagTest =  /(>>|<<)/

SmackVariable = /^$([a-zA-Z0-9_$]+)|^${?([a-zA-Z0-9_$\[\].]+)}/

Whitespace = /^\s+/
