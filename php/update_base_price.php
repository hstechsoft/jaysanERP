<?php
 include 'db_head.php';

 $mtid = test_input($_GET['mtid']);
$mrp = test_input($_GET['mrp']);
$min_price = test_input($_GET['min_price']);
$max_price = test_input($_GET['max_price']);


 
 
function test_input($data) {
$data = trim($data);
$data = stripslashes($data);
$data = htmlspecialchars($data);
$data = "'".$data."'";
return $data;
}


 $sql =  "UPDATE  jaysan_model_type SET  =  $,mrp =  $mrp,min_price =  $min_price,max_price =  $max_price WHERE mtid =  $mtid";

  if ($conn->query($sql) === TRUE) {
   echo "ok";
  } else {
    echo "Error: " . $sql . "<br>" . $conn->error;
  }
$conn->close();

 ?>


