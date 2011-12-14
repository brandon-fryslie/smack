
{last, trim} = require './Helper'

exports.ZenLexer = class ZenLexer
    
  TEST:
    MAIN: 0
    OPENTAG: 0
    WHITESPACE: 0
    FOR_TOKENS: 0
    ELEMENT: 0
    LITERAL: 0
    
  tokenize: (code) ->
        
    @code = code.replace(/\r/g, '')
    @depth = 1
    @tokens = []

    i = 0
    while @chunk = @code.slice i

      i +=  @Element() or
            @AttributeAbbreviation() or
            @AttributeList() or
            @ZenOperator() or
            @TagContent() or
            @ZenAlias() or
            @Whitespace() or
            @LexerError()
                        
    return @tokens

  toke: (tag, value) ->
    @tokens.push [tag, value, @depth]

  tag: (index, tag) ->
    (tok = last @tokens, index) and if tag then tok[0] = tag else tok[0]
  
  value: (index, val) ->
    (tok = last @tokens, index) and if val then tok[1] = val else tok[1]

  check_status: ->
    "chunk" : @chunk

  Element: ->
    return 0 unless match = Element.exec(@chunk)
    [match] = match
    @toke 'ELEMENT', match
    match.length
  
  AttributeAbbreviation: ->
    return 0 unless match = ClassAbbr.exec(@chunk) or match = AttrAbbr.exec(@chunk)
    [match, key, value] = match
    @toke 'ATTRIBUTE', { key, value }
    match.length
  
  AttributeList: ->
    return 0 unless match = AttrList.exec @chunk
    [match, attributes] = match
    
    for attr in attributes.split ','
      [key, value] = attr.split /:\s/
      @toke 'ATTRIBUTE', { key, value }
        
    match.length
    
  ZenOperator: ->
    return 0 unless match = ZenOperator.exec @chunk
    [match] = match
    @toke 'ZEN_OPERATOR', trim match
    
    @depth++ if '>' is trim match
    @depth-- if '<' is trim match
      
    match.length

  TagContent: ->
    return 0 unless match = TagContent.exec @chunk
    [match, content] = match
    @toke 'TAG_CONTENT', trim content
    match.length
    
  ZenAlias: ->
    return 0 unless match = ZenAlias.exec @chunk
    [match, tag, op] = match
    @toke 'ZEN_ALIAS', match
    match.length
  
  Token: ->
    return 0 unless @chunk[0] in Tokens
    @toke @chunk[0], @chunk[0]
    1

  Whitespace: ->
    return 0 unless match = Whitespace.exec @chunk
    return match.length
  
  LexerError: ->
    try
      throw null
    catch e
      console.log '--- ZenLexer Error ---'
      console.log "Not a token: #{@chunk}"
      console.log '@tokens'
      console.log @tokens
      console.log @check_status()
      throw "Fix your lexers"

Element  = /^(?:h[1-6]|[a-zA-Z][a-zA-Z]*)/
ClassAbbr = ///^(\.)([a-zA-Z][a-zA-Z0-9\-_]*)///
AttrAbbr = ///^
            (
              [#.=?:+4]+|\([=*+]\)
            | &[a-z\-]+:
            )
            ([a-zA-Z][a-zA-Z\-_]*)
          ///
AttrKey  = /^[a-zA-Z][a-zA-Z0-9\-_]*/
AttrVal  = /^[a-zA-Z_ ][\-a-zA-Z0-9_ .]*/
AttrList    = /^\|([\s\S]*?)\|/
TagContent  = /^\'([\s\S]*?)\'/

# ZenOperator = /^[>+<]/
ZenOperator = /^[>+<!#]/

Tokens = ['(', ')']

Whitespace = /^\s+/

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
