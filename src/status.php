<?php

header("Content-Type: text/plain");

$ssidhash = md5(time());
$pidfile  = dirname(__FILE__).DIRECTORY_SEPARATOR.'server'.DIRECTORY_SEPARATOR.'php'.DIRECTORY_SEPARATOR.'files'.DIRECTORY_SEPARATOR.$ssidhash.'.pid';
if(@file_put_contents($pidfile, time())){
    if(@file_get_contents($pidfile)){
        @unlink($pidfile);
        echo "1";
        exit;
    }
}else{
  echo "2";
  exit;
}
