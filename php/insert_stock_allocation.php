<?php
 include 'db_head.php';


$allocation_json = json_decode($_POST['allocation_json'], true);



function test_input($data) {
$data = trim($data);
$data = stripslashes($data);
$data = htmlspecialchars($data);
$data = "'".$data."'";
return $data;
}

 
if(count($allocation_json) > 0) {
   
    foreach ($allocation_json as $allocate) {
       $part_id = test_input($allocate['part_id']);
$from_place_id = test_input($allocate['from_place_id']);
$from_place_type = test_input($allocate['from_place_type']);
$to_palce_id = test_input($allocate['to_palce_id']);
$to_place_type = test_input($allocate['to_place_type']);
$qty = test_input($allocate['qty']);
$req_no = test_input($allocate['req_no']);
$allocation_cat = test_input($allocate['allocation_cat']);


 $sql = "INSERT INTO stock_allocation ( part_id,from_place_id,from_place_type,to_palce_id,to_place_type,qty,req_no,allocation_cat) VALUES ($part_id,$from_place_id,$from_place_type,$to_palce_id,$to_place_type,$qty,$req_no,$allocation_cat)";

  if ($conn->query($sql) === TRUE) {
  
  } else {
    echo "Error: " . $sql . "<br>" . $conn->error;
  }
    }
  }
 
echo "ok";




$conn->close();

 ?>


