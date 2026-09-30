<?php
require_once 'stockservice.php';

$stockservice = new stockservice();
$stockservice -> consumestock();
    


$stockservice -> addstock();