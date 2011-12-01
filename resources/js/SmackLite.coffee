require('coffee-script')

# SmackLite
# 
# ~|> p#id.class.another-class Data |~
  


class SmackLite
  
  constructor: ->
    
  smack: (s) ->
    matches = @TAG_REV.exec s
    throw 'No Tag!' unless matches?

    [ match, literal, tag, addl_tags ] = matches
    
    head = @smack_el tag
    
    el_match = /^<([a-zA-Z][a-zA-Z0-9]*)/.exec(head)
    throw "Smack El error" unless el_match?
    [match, el] = el_match
    
    cont = literal
    foot = '</'+el+'>'
    
    console.log "matches: #{match}"
    console.log "literal: #{literal}"
    console.log "tag: #{tag}"
    console.log "addl_tags: #{addl_tags}"
    
    console.log matches
    
    
    
  
  test: ->
    @smack @s_rev
  
  # Smack the tag
  # Return a stack of top tags so we can close them later
  smack_el: (s) ->
    tag_stack = []
    matches = ///^
                  ([a-zA-Z][a-zA-Z0-9]*)\s* # El
                  (\#[a-zA-Z][a-zA-Z0-9\-_]*)\s* # Id
                  ((?:\.[a-zA-Z][a-zA-Z0-9\-_]*)+)\s* # Classes
                  ([|][^|]*[|])\s* # Attrs
              $///m.exec s
    [match, el, id, classes, attrs] = matches
      
    tag_stack.push el
    
    classes = if classes? then 'class="'++'"' else ''
    
    console.log "matches: #{matches}"
    console.log "el: #{el}"
    console.log "id: #{id}"
    console.log "classes: #{classes}"
    console.log "attrs: #{attrs}"
    
  s_fwd: "~|> p#status.block-message |alt:Bla Bla Bla| > div.clear-fix~ You have Success!!! |~"
  s_rev: "~| You have Success!!! ~p#status.block-message |alt:Bla Bla Bla| > div.clear-fix |~"
  
  TAG_FWD: ///^
          ~[|]>\s* # Open Tag
          ( 
            (?:[a-zA-Z][a-zA-Z0-9]*)?\s* # El
            (?:(?:\#[a-zA-Z][a-zA-Z0-9\-_]*))?\s* # Id
            (?:(?:\.[a-zA-Z][a-zA-Z0-9\-_]*)+)?\s* # Classes
            (?:[|][^|]*[|])?\s* # Attrs
          )
          ( 
            >\s* # Smack operator
            (?:[a-zA-Z][a-zA-Z0-9]*)?\s* # El
            (?:(?:\#[a-zA-Z][a-zA-Z0-9\-_]*))?\s* # Id
            (?:(?:\.[a-zA-Z][a-zA-Z0-9\-_]*)+)?\s* # Classes
            (?:[|][^|]*[|])?\s* # Attrs
          )*
          ~\s # Midtag
          ([\s\S]*) # Literal
          \s[|]~ # Close Tag
        $///m

  TAG_REV: ///^
          ~[|]\s+ # Open Tag
          ([\s\S]*) # Literal
          \s~ # Midtag
          ( 
            (?:[a-zA-Z][a-zA-Z0-9]*)?\s* # El
            (?:(?:\#[a-zA-Z][a-zA-Z0-9\-_]*))?\s* # Id
            (?:(?:\.[a-zA-Z][a-zA-Z0-9\-_]*)+)?\s* # Classes
            (?:[|][^|]*[|])?\s* # Attrs
          )
          ( 
            \s*>\s* # Smack operator
            (?:[a-zA-Z][a-zA-Z0-9]*)?\s* # El
            (?:\#[a-zA-Z][a-zA-Z0-9\-_]*)?\s* # Id
            (?:(?:\.[a-zA-Z][a-zA-Z0-9\-_]*)+)?\s* # Classes
            (?:[|][^|]*[|])?\s* # Attrs
          )*
          \s[|]~ # Close Tag
        $///m

smk = new SmackLite

smk.test()