<?php
 include 'db_head.php';



 
 
function test_input($data) {
$data = trim($data);
$data = stripslashes($data);
$data = htmlspecialchars($data);
$data = "'".$data."'";
return $data;
}

$sql = "SELECT (with dcf_assign as (SELECT dcf.dcf_id,assign_product.opid FROM `dcf` inner join assign_product on dcf.dcf_id = assign_product.dcf_id ),
sop_details as (SELECT dcf_assign.*,sop.oid from dcf_assign inner join sales_order_product sop on dcf_assign.opid = sop.opid)
SELECT ul('', li_class('',concat(p('m-0 p-0 fw-bold',sof.order_no),p('m-0 p-0 small',date_only(sof.dated))))) from sop_details inner join sales_order_form sof on sof.oid = sop_details.oid WHERE dcf_id = dcf1.dcf_id GROUP by sof.oid LIMIT 1) as oi, dcf1.dcf_id,dcf1.dated,dcf1.consignee,dcf1.sts,DATE_FORMAT(dcf1.dated, '%d-%m-%Y') as dated,employee.emp_name FROM dcf dcf1 INNER join employee on dcf1.dcf_by = employee.emp_id WHERE 1 ORDER by dcf_by";

//  $sql = "SELECT  dcf1.dcf_id,dcf1.dated,dcf1.consignee,dcf1.sts,DATE_FORMAT(dcf1.dated, '%d-%m-%Y') as dated,employee.emp_name FROM dcf dcf1 INNER join employee on dcf1.dcf_by = employee.emp_id WHERE 1 ORDER by dcf_by ";

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




