
Smack = this.Smack

$ ->
  $('#smack_input').val """
    ~| Hi there! ~p |~
    ~|> p#status.block-message |alt:Bla Bla Bla| > div.clear-fix~ You have Success!!! |~
    ~| You have Success!!! ~p#status.block-message |alt:Bla Bla Bla| > div.clear-fix |~
  """
  
  
  $("#smack_input").val """
~|split |> p + p + p + p >>
  Whoa | Bro | Low | Blow!
|~
~|split |> p > p > p > p >>
  Whoa Bro Low Blow!
|~
  """
  
  $("#smack_input").bind "input", ->
    try
      $('#text_output').html _.str.escapeHTML Smack.compile @value
      
      $('#tokens_output').html ("#{tag}: '#{value}'<br>" for [tag, value] in Smack.tokens @value).join ' '
          
      # $('#tokens_output').html _.str.escapeHTML(s).replace(/\n/g, '<br>').replace(/\x20/, "&nbsp;&nbsp;&nbsp;&nbsp;")
      $('#nodes_output').html "Coming soon:  to_s methods for the nodes!"
      $('#error').html ''
    catch e
      $('#text_output').html ''
      $('#tokens_output').html ''
      $('#error').html e
      
  $('#smack_input').trigger('input')