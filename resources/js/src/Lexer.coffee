
# Smack Tag
#
# Simple Edition
#
# ~|> p#status.block-message~ Upload Successful! |~
# ~| Upload Successful! ~p#status.block-message |~
#
# ~|>
#   p#status.block-message |alt: Bla Bla Bla| > div.clear-fix
# ~
#   Upload Successful!
# |~
#
# ~| Upload Successful! ~p#status.block-message |alt: Bla Bla Bla| > div.clear-fix |~
#


exports.Lexer = class Lexer
    
  TEST:
    MAIN: 0
    OPENTAG: 0
    WHITESPACE: 0
    FOR_TOKENS: 0
    ELEMENT: 0
    LITERAL: 0
    
  tokenize: (code) ->
    
    console.log "tokenizing code: #{code}" if @TEST?.MAIN
    
    @code = code.replace(/\r/g, '')
    @line = 0
    @tokens = []

    i = 0
    while @chunk = @code.slice i
      
      console.log "main@in_config(): #{@in_config()}" if @TEST?.MAIN

      open_tag_idx = (token, i) ->
        if token[0] == 'OPENTAG' then return i else token

      @for_tokens ->
        open_tag_idx

      console.log @chunk if @TEST?.MAIN
      
      i +=  @OpenTag() or
            @SmackOperator() or
            @Midtag() or
            @CloseTag() or
            @Element() or
            @AttributeAbbreviation() or
            @AttributeList() or
            @ZenOperator() or
            @Literal() or
            @Whitespace() or
            @LexerError()
                    
    @closeTags()
    
    return @tokens

  closeTags: ->
    '</div>'

  # Runs a fn over the tokens backward
  for_tokens: (fn) ->
    console.log '@for_tokens:' if @TEST?.FOR_TOKENS
    console.log @tokens if @TEST?.FOR_TOKENS
    store = null
    res = null
    i = @tokens.length
    while i--
      return res if res?
      do (i, store) =>
        [tag, value] = token = @tokens[i]
        v = fn(arguments)
        if v?.length > 0 and v?[0] is 'return' then return (if v.length > 1 then v[1] else v[1..])

  
  # # Are we in a smack tag?
  # in_tag: ->
  #   for i in [@tokens.length-1..0] when @tokens.length
  #     if @tokens[i][0] is 'OPENTAG'
  #       return true
  #     if @tokens[i][0] is 'CLOSETAG'
  #       return false
  #   return false

  # True if the last tag is a reverse tag like ~| Hi! ~p |~
  is_reverse: -> @last_operator is ' '
  
  # True if we are currently in a tag
  in_tag: no
  
  # True if we are in the config section
  _in_config: no
  in_config: -> @in_tag and @_in_config
  
  last: (array, back) ->
    array[array.length - (back or 0) - 1]

  tag: (index, tag) ->
    (tok = @last @tokens, index) and if tag then tok[0] = tag else tok[0]
  
  value: (index, val) ->
    (tok = @last @tokens, index) and if val then tok[1] = val else tok[1]

  check_status: ->
    "In tag?": @in_tag
    "In tag config": @in_config()
    "reverse?" : @is_reverse()
    "tag()": @tag()
    "chunk": @chunk

  OpenTag: ->
    console.log 'Opentag w/ chunk:'+@chunk if @TEST?.OPENTAG
    console.log 'Opentag RE:'+OpenTagRE if @TEST?.OPENTAG
    return 0 unless match = OpenTagRE.exec @chunk
    console.log 'Opentag matched' if @TEST?.OPENTAG
    [match, tag] = match
    @tokens.push [ 'OPENTAG', tag ]
    @in_tag = yes
    @_in_config = yes
    match.length
  
  SmackOperator: ->
    return 0 unless @tag() and @tag() is 'OPENTAG' and
      match = SmackOperatorRE.exec(@chunk)
          
    @tokens.push [ 'SMACK_OPERATOR', match[0] ]
    
    @last_operator = match[0]
    
    @_in_config = match[0] isnt ' '
        
    match[0].length
  
  Midtag: ->
    return 0 unless @in_tag and
      match = MidtagRE.exec(@chunk)
    [match, tag] = match
    @tokens.push [ 'MIDTAG', tag ]
    @_in_config =  !@in_config()
    match.length
  
  CloseTag: ->
    return 0 unless @in_tag and (@tag() is 'LITERAL' or @in_config()) and
      match = CloseTagRE.exec(@chunk)
      
    [match, op, tag] = match
    
    @tokens.push [ 'SMACK_OPERATOR', op ]
    @tokens.push [ 'CLOSETAG', tag ]
    @in_tag = no
    @_in_config = no
    match.length
  
  Element: ->
    return 0 unless @in_config() and
      match = Element.exec(@chunk)
    [match, tag, op] = match
    @tokens.push [ 'ELEMENT', match ]
    match.length
  
  AttributeAbbreviation: ->
    return 0 unless @in_config() and match = AttrAbbr.exec @chunk
    [match, key, value] = match
    @tokens.push [ 'ABBREVIATED_ATTRIBUTE', { key, value } ]
    match.length
  
  AttributeList: ->
    return 0 unless @in_config() and match = AttrList.exec @chunk
    
    @tokens.push [ 'ATTR_LIST_OPEN', match[1] ]
    
    # console.log 'match'
    # console.log match
    for attr in match[2].split ','
      [key, value] = attr.split /:\s/
      @tokens.push ['ATTRIBUTE', { key, value }]
    
    @tokens.push [ 'ATTR_LIST_CLOSE', match[3] ]
    
    match[0].length
    
  ZenOperator: ->
    return 0 unless match = ZenOperator.exec @chunk
    [match, tag, op] = match
    console.log 'zenop' if @TEST?.ZENOP
    @tokens.push [ 'ZEN_OPERATOR', match ]
    match.length
    
  SmackVariable: ->
    return 0 unless match = SmackVariableRE.exec @chunk
    [match, tag, op] = match
    console.log 'smackvar' if @TEST?.SMACKVAR
    @tokens.push [ 'SMACK_VARIABLE', match ]
    match.length
    
  SmackAlias: ->
    return 0 unless match = SmackAliasRE.exec @chunk
    [match, tag, op] = match
    console.log 'alias' if @TEST?.SMACKALIAS
    @tokens.push [ 'SMACK_ALIAS', match ]
    match.length
  
  # Literal text
  # Any characters not in a smack tag or variable
  Literal: ->
    return 0 if @in_config() or @tag() is 'LITERAL'
    
    # Implement recursion here
    open_idx = OpenTagTest.exec(@chunk)?.index ? @chunk.length
    
    this_close_idx = if not @is_reverse() and @tag() is 'MIDTAG'
      close_idx = CloseTagTest.exec(@chunk)?.index ? @chunk.length
    else if @is_reverse and @tag() is 'SMACK_OPERATOR' and @value() is ' '
      close_idx = MidtagTest.exec(@chunk)?.index ? @chunk.length

    return 0 unless this_close_idx
    
    literal = @chunk[0...this_close_idx]

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
      throw "Fix your lexers"
    tok = @chunk[0]
    @tokens.push [ 'TOKEN', tok ]
    tok.length


Element  = /^[a-zA-Z][a-zA-Z0-9]*/
AttrAbbr = ///^([#.]+)([a-zA-Z][a-zA-Z0-9\-_]*)///
AttrKey  = /^[a-zA-Z][a-zA-Z0-9\-_]*/
AttrVal  = /^[a-zA-Z_ ][\-a-zA-Z0-9_ .]*/
AttrList = /^(\|)([\s\S]*?)(\|)/


Whitespace = /^\s+/

# Smack operator
SmackOperatorRE   = /^([\S]*?>|\x20)/
SmackOperatorTest = /([\S]*?>|\x20)/
SmackAliasRE      = /^@[a-zA-Z0-9_\-$]+/
SmackVariableRE   = /^$([a-zA-Z0-9_$]+)|${?([a-zA-Z0-9_$\[\].]+)}/

ZenOperator = /^[>+]/

OpenTagRE    = /^(~[|])/
OpenTagTest  = /(~[|])/
CloseTagRE   = /^(~>[\S]*?|\x20)([|]~)/
CloseTagTest = /(~>[\S]*?|\x20)([|]~)/

# added (?!>) to disambiguate with closetag
MidtagRE    = /^(~[\s]|[\s]~(?!>))/
MidtagTest  = /(~[\s]|[\s]~(?!>))/

