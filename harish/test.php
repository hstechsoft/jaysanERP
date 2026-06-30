<?php
require 'stockservice.php';

$stockservice = new stockservice();
$stockservice -> consumestock();
    


$stockservice -> addstock();