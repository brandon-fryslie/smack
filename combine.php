<?php

ini_set('display_errors', 1);
error_reporting(E_ALL);

define('RESOURCE_PATH', '/Library/WebServer/Documents/shared');

require_once(RESOURCE_PATH.'/php/combine/Combiner.class.php');

$combo = new Combiner(array(
      'combine_path' => RESOURCE_PATH.'/php/combine',
      // 'css_image_path' => 'localhost',
      '/fr-view/resources/css/images',
      'paths' => array(
        RESOURCE_PATH,
        'resources'
      )
));

$combo->get();

?>