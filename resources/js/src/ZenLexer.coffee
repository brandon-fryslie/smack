
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
    @line = 0
    @tokens = []

    i = 0
    while @chunk = @code.slice i

      i +=  @Element() or
            @AttributeAbbreviation() or
            @AttributeList() or
            @ZenOperator() or
            @ZenPopulator() or
            @ZenAlias() or
            @Whitespace() or
            @LexerError()
                        
    return @tokens

  last: (array, back) ->
    array[array.length - (back or 0) - 1]

  tag: (index, tag) ->
    (tok = @last @tokens, index) and if tag then tok[0] = tag else tok[0]
  
  value: (index, val) ->
    (tok = @last @tokens, index) and if val then tok[1] = val else tok[1]

  check_status: ->
    "chunk" : @chunk

  Element: ->
    return 0 unless match = Element.exec(@chunk)
    [match] = match
    @tokens.push [ 'ELEMENT', match ]
    match.length
  
  AttributeAbbreviation: ->
    return 0 unless match = ClassAbbr.exec(@chunk) or match = AttrAbbr.exec(@chunk)
    [match, key, value] = match
    @tokens.push [ 'ABBREVIATED_ATTRIBUTE', { key, value } ]
    match.length
  
  AttributeList: ->
    return 0 unless match = AttrList.exec @chunk
    @tokens.push [ 'ATTR_LIST_OPEN', match[1] ]
    for attr in match[2].split ','
      [key, value] = attr.split /:\s/
      @tokens.push ['ATTRIBUTE', { key, value }]
    
    @tokens.push [ 'ATTR_LIST_CLOSE', match[3] ]
    
    match[0].length
    
  ZenOperator: ->
    return 0 unless match = ZenOperator.exec @chunk
    [match, tag, op] = match
    @tokens.push [ 'ZEN_OPERATOR', match ]
    match.length

  ZenPopulator: ->
    return 0 unless match = ZenPopulator.exec @chunk
    [match, tag, op] = match
    @tokens.push [ 'ZEN_POPULATOR', match ]
    match.length
    
  ZenAlias: ->
    return 0 unless match = ZenAlias.exec @chunk
    [match, tag, op] = match
    @tokens.push [ 'ZEN_ALIAS', match ]
    match.length

  Whitespace: ->
    return 0 unless match = Whitespace.exec @chunk
    return match.length
  
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
AttrList = /^(\')([\s\S]*?)(\')/

ZenOperator = /^[>+<]/

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
