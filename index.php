<?php

if ($_SERVER['HTTP_HOST'] == 'localhost')
{
  $resource_path = 'http://localhost/smack';
  $app_path = "$resource_path/resources/node-load.php";  
}
else if ($_SERVER['HTTP_HOST'] == 'cgi.cs.arizona.edu')
{
  $resource_path = 'http://cgi.cs.arizona.edu/~bmf/smack';
  $app_path = "$resource_path/combine.php/js/mini:no/SmackCompiler";  
}
else
  die('Unknown HTTP_HOST: '+$_SERVER['HTTP_HOST']);

$tpl = <<<HTML

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"
  "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
  <script src="{$resource_path}/combine.php/js/mini:yes/jquery.min,underscore-min,underscore.string,backbone,bootstrap-tabs"></script>
  <script src="{$app_path}"></script>
  <script src="{$resource_path}/combine.php/js/mini:no/scripts"></script>
  <link rel="stylesheet" href="{$resource_path}/combine.php/css/mini:no/bootstrap.min">  
  <style>
    .container > footer p {
      text-align: center; /* center align it with the container */
      font-weight: bold;
      font-variant: small-caps;
    }
    /* Page header tweaks */
    .page-header {
      background-color: #f5f5f5;
      padding: 20px 20px 10px;
      margin: -20px -20px 20px;
    }
    .page-header > h1
    {
      text-align: center;
    }
    .content {
      background-color: #fff;
      padding: 20px;
      margin: 0 -20px; /* negative indent the amount of the padding to maintain the grid system */
      -webkit-border-radius: 0 0 6px 6px;
         -moz-border-radius: 0 0 6px 6px;
              border-radius: 0 0 6px 6px;
      -webkit-box-shadow: 0 1px 2px rgba(0,0,0,.15);
         -moz-box-shadow: 0 1px 2px rgba(0,0,0,.15);
              box-shadow: 0 1px 2px rgba(0,0,0,.15);
    }
    html, body
    {
      background-color: #eee;
    }
    #smack_input
    {
      width: 400px; height: 450px;
    }
    .smack_output
    {
      padding: 5px;
      width: 400px; height: 450px;
      border: 1px solid #CCC;
      background-color: #FFF;
    }
    .tab-pane
    {
      overflow: auto;
    }
    #error
    {
      width: 400;
      color: red;
      font-weight: bold;
    }
    #output_div h3
    {
      width: 150px;
      display: inline;
    }
    #output_tabs
    {
      float: right;
      width: 243px;
      right: 59px;
      display: inline;
      position: relative;
      margin-bottom: 0px;
      top: 1px;
    }
    #output_div .tab-content
    {
      padding: 0;
    }
    #output_div .tab-content p
    {
      margin: 0;
    }
  </style>
</head>
<body>

 <div class="container">

  <div class="content">
    <div class="page-header">
      
      <h1>Smack</h1>
      <script type="text/smack">
        ~| cuz life is too short to be writing HTML << h1 > small |~
      </script>
    </div>
    <div class="row">
      <div class="span8">
        <h3>Enter this:</h3>
        <textarea id="smack_input"></textarea>
      </div>
      <div class="span8" id="output_div">
        <h3>And you get this!</h3>
        <ul class="tabs" id="output_tabs" data-tabs="tabs">
          <li class="active"><a href="#text_output">Output</a></li>
          <li><a href="#tokens_output">Tokens</a></li>
          <li><a href="#nodes_output">Nodes</a></li>
        </ul>
        <div class="tab-content">
          <p id="text_output" class="smack_output active tab-pane"></p>
          <p id="tokens_output" class="smack_output tab-pane"></p>
          <p id="nodes_output" class="smack_output tab-pane"></p>
        </div>
        <p id="error"></p>
      </div>
    </div>
  </div>

  <footer>
    <p>$ Aw Yee $</p>
  </footer>

  </div> <!-- /container -->

</body>
</html>
HTML;

echo $tpl;

?>