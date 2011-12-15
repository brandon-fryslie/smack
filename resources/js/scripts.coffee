
Smack = this.Smack

$ ->
  $('#smack_input').val """
    ~| Hi there! ~p |~
    ~|> p#status.block-message |alt:Bla Bla Bla| > div.clear-fix~ You have Success!!! |~
    ~| You have Success!!! ~p#status.block-message |alt:Bla Bla Bla| > div.clear-fix |~
  """
  
  
  $("#smack_input").val """
~| img input |~
  
~| div.alert-message.block-message.info |~

~|> p >> Yo bro! |~
~| Yo bro! << p |~

~|
div.topbar
  > div.fill
    > div.container-fluid
      > 'RV' a.brand |href: #|
      + ul.nav |data-tabs: tabs|
        > li.active > 'Recruitment Viewer' a |href: #viewer-tab| <
        + li.dropdown |data-dropdown: dropdown|
          > 'Documentation' a.dropdown-toggle |href: #doc-tab|
          + ul.dropdown-menu
            > 'Gene Annotation' li > a+doc-iframe |href: resources/docs/1_gene_annotation.html| <
            + 'HPC' li > a+doc-iframe |href: resources/docs/2_HPC.html| <
            + 'Blast' li > a+doc-iframe |href: resources/docs/3_Blast.html| <
            + 'Newbler' li > a+doc-iframe |href: resources/docs/4_Newbler.html| <
|~

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
  
  $("#smack_input").bind "input", ->
    try
      $('#text_output').html _.str.escapeHTML(Smack.compile @value).replace /\n/g, '<br>'
      
      $('#tokens_output').html ("#{tag}: '#{value}'<br>" for [tag, value] in Smack.tokens @value).join ' '
          
      # $('#tokens_output').html _.str.escapeHTML(s).replace(/\n/g, '<br>').replace(/\x20/, "&nbsp;&nbsp;&nbsp;&nbsp;")
      $('#nodes_output').html "Coming soon:  to_s methods for the nodes!"
      $('#error').html ''
    catch e
      $('#text_output').html ''
      $('#tokens_output').html ''
      $('#error').html e
      
  $('#smack_input').trigger('input')