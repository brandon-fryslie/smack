
{last, trim} = require './Helper'
{VARIABLE, ALIAS} = require './ZenConfig'

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

      i +=  @ZenAlias() or
            @Element() or
            @AttributeAbbreviation() or
            @AttributeList() or
            @ZenOperator() or
            @TagContent() or
            @Whitespace() or
            @Unknown()
                        
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
    return 0 unless match = AttrAbbr.exec(@chunk) or ExtendedAttrAbbr.exec(@chunk) or PrimaryAttrAbbr.exec(@chunk)
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
    return 0 unless match = TagContentString.exec(@chunk) or TagContentVariable.exec(@chunk)
    [match, op, content] = match
    
    if op is '$'
      content = VARIABLE.resolve(content)
    
    # Disambiguate for the grammar
    if @tag() is 'ZEN_OPERATOR'
      @toke 'TAG_FRONT_CONTENT', trim content
    else
      @toke 'TAG_CONTENT', trim content
    match.length
    
  ZenAlias: ->
    return 0 unless match = ZenAlias.exec @chunk
    [match, identifier, args] = match
    
    # We deal with Aliases right here so they can join the token
    # stream just like normal zen tags
    @code = @chunk = ALIAS.resolve(identifier, args) + @code[match.length...]
    0
  
  Token: ->
    return 0 unless @chunk[0] in Tokens
    @toke @chunk[0], @chunk[0]
    1

  Whitespace: ->
    return 0 unless match = Whitespace.exec @chunk
    return match.length
  
  Unknown: ->
    if @tag() is 'UNKNOWN'
      [tag, value] = @tokens.pop()
      @toke value+@chunk[0]
      return value.length+1
    @toke @chunk[0]
    1
  

Element  = /^(?:h[1-6]|[a-zA-Z][a-zA-Z]*)/

# ID, Class, For, Type, data-
# These only need alphanumerics, _ and -
AttrAbbr = /^([#.]|::|&[a-z\-]+:)([a-zA-Z][a-zA-Z0-9\-_]*)/

# Value (=), Target (+), Action (!)
# These need a wider variety of characters
# Special case http: so we can catch : at the end
ExtendedAttrAbbr = /^\(([4=+!]|[a-z]+)\)((?:http:)?[^(\s:]+)/

# : accesses the primary attribute for that element
PrimaryAttrAbbr = /^(:)([^(\s]+)/

AttrList            = /^\|([\s\S]*?)\|/
TagContentString    = /^(w?)\'([\s\S]*?)\'/
TagContentVariable  = /^(\$)([a-zA-Z0-9_-]+)/
ZenOperator         = /^[>+<!#]/
Whitespace          = /^\s+/
ZenAlias            = /^@([a-zA-Z0-9\-_\.]+)(?:\(([^)]*)\))?/
