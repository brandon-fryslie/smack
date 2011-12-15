<?php

class NodeLoad
{
  public function __construct ($path, $coffee_file)
  {
    $this->path = $path;
    $this->coffee_file = $coffee_file;
    $this->args = array();
    $this->subdirs = false;
  }
  
  private function error ($error)
  {
    echo "<pre>Error: $error</pre>";

    exit;
  }

  public function get ()
  {    
    header ("Content-Type: text/javascript");
    
    chdir($this->path);

    echo $this->compile('coffee', "-b {$this->coffee_file}");
    
    `make clean`;
  }
  
  // Compiles stuff with $command
  // Right now, used for less & coffeescript
  private function compile ($command, $args)
  {
    $spec = array(
      0 => array('pipe', 'r'),
      1 => array('pipe', 'w'),
      2 => array('pipe', 'w')
    );

    $env = array(
      'NODE_PATH' => '/usr/local/lib/node',
      'PATH' => '/usr/local/bin:'.getenv('PATH')
    );

    $proc = proc_open("$command $args", $spec, $pipes, null, $env);

    if (!is_resource($proc))
      $this->error("proc_open failed: couldn't open the command line utility $command");

    fclose($pipes[0]);

    $rv = stream_get_contents($pipes[1]);
    $err = stream_get_contents($pipes[2]);

    fclose($pipes[1]);
    fclose($pipes[2]);

    $proc_value = proc_close($proc);

    if ($err !== '') $this->error($err);

    return $rv;
  }
}

$combo = new NodeLoad('js/src/', 'NodeLoad.coffee');
$combo->get();

?>