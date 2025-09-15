<?php
 include 'db_head.php';




 
 
function test_input($data) {
$data = trim($data);
$data = stripslashes($data);
$data = htmlspecialchars($data);
$data = "'".$data."'";
return $data;
}


$sql = "SET time_zone = '+05:30';"; // First query to set the time zone
$sql .= "SELECT hs1.order_no,hs1.sub_type,hs1.ass_date as date_f,hs1.ass_id,hs1.oid,(SELECT jaysan_final_product.product_name from  jaysan_final_product WHERE jaysan_final_product.product_id = jaysan_product_model.product_id) as product,employee.emp_name,jaysan_product_model.model_name as model,customer.cus_name,
customer.cus_phone,jaysan_model_type.type_name as type FROM
( SELECT sales_order_form.order_no,sales_order_form.oid,hs.type_id,hs.model_id,hs.sub_type,sales_order_form.customer_id,sales_order_form.emp_id,sales_order_form.dated,hs.ass_date,hs.ass_id
    FROM
        (
        SELECT
            sales_order_product.*,
            assign_product.ass_id
       
            ,DATE_FORMAT(assign_product.dated, '%d-%m-%Y %h:%i %p') as ass_date
        FROM
            assign_product
        INNER JOIN sales_order_product ON sales_order_product.opid = assign_product.opid
    ) AS hs
INNER JOIN sales_order_form ON hs.oid = sales_order_form.oid
) AS hs1
INNER JOIN jaysan_model_type ON jaysan_model_type.mtid = hs1.type_id
INNER JOIN customer ON hs1.customer_id = customer.cus_id
INNER JOIN jaysan_product_model ON hs1.model_id = jaysan_product_model.model_id
INNER JOIN employee ON hs1.emp_id = employee.emp_id";


// SELECT assign_product.ass_id,sales_order_form.order_no,employee.emp_name, customer.cus_name,customer.cus_phone ,(SELECT jaysan_product_model.model_name from jaysan_product_model WHERE jaysan_product_model.model_id = sales_order_product.model_id) as model,(SELECT jaysan_model_type.type_name FROM jaysan_model_type WHERE jaysan_model_type.mtid = sales_order_product.type_id) as type,(SELECT jaysan_final_product.product_name from jaysan_final_product WHERE jaysan_final_product.product_id = (SELECT jaysan_product_model.product_id from jaysan_product_model WHERE jaysan_product_model.model_id = sales_order_product.model_id)) as product,sales_order_form.oid,sales_order_product.sub_type,DATE_FORMAT(sales_order_form.dated, '%d-%m-%Y %h:%i %p') as date_f from sales_order_product INNER join assign_product on sales_order_product.opid = assign_product.opid INNER join sales_order_form on sales_order_product.oid = sales_order_product.oid INNER JOIN customer ON sales_order_form.customer_id = customer.cus_id  INNER join employee on sales_order_form.emp_id = employee.emp_id WHERE 1 GROUP by assign_product.ass_id  ORDER by assign_product.ass_id ASC 



if ($conn->multi_query($sql)) {
    // Move to the second result set
    $conn->next_result();
    $result = $conn->store_result();

    if ($result->num_rows > 0) {
        $rows = array();
        while($r = $result->fetch_assoc()) {
            $rows[] = $r;
        }
        print json_encode($rows);
    } else {
        echo "0 result";
    }

    $result->free();
} else {
    echo "Error: " . $conn->error;
}
$conn->close();

 ?>


