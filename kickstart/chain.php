<?php
  header("Content-type: text/plain");
  echo "#!ipxe\n";
  $ip = $_REQUEST["ip"];
  $mac = $_REQUEST["mac"];
  if ($ip=="10.0.2.15") {
    echo "set value fedora\n";
    echo "set os Fedora\n";
    echo "set version 16\n";
    echo "set bt normal\n";
  }
?>
chain http://www.salstar.sk/pxe/ipxe/script.ipxe
