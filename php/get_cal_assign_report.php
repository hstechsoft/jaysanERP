<?php
 include 'db_head.php';

 
$dated = test_input($_GET['dated']);



 
 
function test_input($data) {
$data = trim($data);
$data = stripslashes($data);
$data = htmlspecialchars($data);
$data = "'".$data."'";
return $data;
}
$sql = "SET time_zone = '+05:30';"; 
$sql .= "SELECT count(*) as qty, opid, concat('<div class=\"d-flex justify-content-center gap-2 p-1 \">
<p class=\"small  m-0 p-0\">',(SELECT jaysan_final_product.product_name FROM jaysan_final_product WHERE jaysan_final_product.product_id = jaysan_product_model.product_id),'</p>  <p class=\"small m-0 p-0\">', jaysan_product_model.model_name,'</p> <p class=\"small  m-0 p-0\">',jaysan_model_type.type_name,'</p>','<p class=\" m-0 p-0 small \"> Qty :',count(*), '</p></div><p class=\" m-0 p-0 small text-muted\">',pm.sub_type,'</p>'  ) as product , sales_order_form.customer_id,(SELECT concat(customer.cus_name , ' - ' , customer.cus_phone) from customer WHERE customer.cus_id = sales_order_form.customer_id) as customer from (SELECT sales_order_product.opid,sales_order_product.oid,sales_order_product.type_id,sales_order_product.model_id,sales_order_product.sub_type,sales_order_product.required_qty FROM `assign_product` INNER join sales_order_product on assign_product.opid = sales_order_product.opid WHERE assign_product.dated = $dated and assign_product.assign_type = 'Production')as pm inner JOIN jaysan_product_model on pm.model_id = jaysan_product_model.model_id inner JOIN jaysan_model_type on pm.type_id = jaysan_model_type.mtid INNER join sales_order_form on pm.oid = sales_order_form.oid  GROUP by customer_id,opid";

// Execute the multi_query
if ($conn->multi_query($sql)) {
    // This loop is used to handle multiple result sets
    do {
        // Store the result set from the query
        if ($result = $conn->store_result()) {
            if ($result->num_rows > 0) {
                $rows = array();
                while($r = $result->fetch_assoc()) {
                    $rows[] = $r;
                }
                // Output the result as JSON
                print json_encode($rows);
            } else {
                echo "0 result";
            }
            $result->free(); // Free the result set
        }
        // Check if there are more result sets
    } while ($conn->more_results() && $conn->next_result());
} else {
    // If the multi_query fails, output the error
    echo "Error: " . $conn->error;
}
$conn->close();

 ?>


