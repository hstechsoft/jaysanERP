<?php
 include 'db_head.php';

 
 $emp_id = test_input($_GET['emp_id']);
 $start_date = ($_GET['start_date']);
 $end_date = ($_GET['end_date']);

 
function test_input($data) {
$data = trim($data);
$data = stripslashes($data);
$data = htmlspecialchars($data);
$data = "'".$data."'";
return $data;
}
$sql = "SELECT * from policy_report WHERE dated between  $start_date and  $end_date and emp_name = $emp_id ";

// $sql = "SELECT work.work_description,work.cus_id,work_history.his_date,work_history.comments,work_history.his_status,work.work_type FROM work_history INNER JOIN work ON work_history.work_id = work.work_id WHERE work_history.emp_id = $emp_id and work_history.his_date between  $start_date and  $end_date  ORDER BY work_history.his_date ";


$result = $conn->query($sql);

if ($result->num_rows > 0) {
    $rows = array();
    while($r = mysqli_fetch_assoc($result)) {
        $rows[] = $r;
    }
    print json_encode($rows);
} else {
  echo "0 result";
}
$conn->close();

 ?>


