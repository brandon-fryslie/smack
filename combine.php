<?php

ini_set('display_errors', 1);
error_reporting(E_ALL);

if ($_SERVER['HTTP_HOST'] == 'localhost')
  define('RESOURCE_PATH', '/Library/WebServer/Documents');
else if ($_SERVER['HTTP_HOST'] == 'cgi.cs.arizona.edu')
  define('RESOURCE_PATH', '/home/bmf/public_html');


$combine_path = RESOURCE_PATH.'/shared/php/combine';

require_once(RESOURCE_PATH.'/shared/php/combine/Combiner.class.php');

$combo = new Combiner(array(
      'combine_path' => RESOURCE_PATH.'/shared/php/combine',
      // 'css_image_path' => 'localhost',
      // '/smack/resources/css/images',
      'paths' => array(
        RESOURCE_PATH.'/shared',
        RESOURCE_PATH.'/smack/resources',
        // '/var/www/zuni/cgi-bin/people/bmf/public_html/smack/resources'
      )
));

$combo->get();

?>