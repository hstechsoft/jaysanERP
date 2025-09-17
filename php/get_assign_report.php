<?php
 include 'db_head.php';

 



$date_query = ($_GET['date_query']);
 $emp_id = ($_GET['emp_id']);
 $sub_type = ($_GET['sub_type']);
  $model = ($_GET['model']);
   $type = ($_GET['type']);
 
function test_input($data) {
$data = trim($data);
$data = stripslashes($data);
$data = htmlspecialchars($data);
$data = "'".$data."'";
return $data;
}
$sql = "SET time_zone = '+05:30';"; 
$sql .= "SELECT

    assign_data.*,
    IFNULL(SUM(pma.qty),
    0) AS modify_qty,
    GROUP_CONCAT(
        CONCAT(
            '<p class=\"small\">',
            pma.dated,
            ' - ',
            pma.qty,
            '<\p>'
        )
    ) AS date_info
FROM
    (
    SELECT
        COUNT(*) AS qty,
        opid,
        CONCAT(
            '<div class=\"d-flex justify-content-center gap-2 p-1 \">
<p class=\"small  m-0 p-0\">',
            (
            SELECT
                jaysan_final_product.product_name
            FROM
                jaysan_final_product
            WHERE
                jaysan_final_product.product_id = jaysan_product_model.product_id
        ),
        '</p>  <p class=\"small m-0 p-0\">',
        jaysan_product_model.model_name,
        '</p> <p class=\"small  m-0 p-0\">',
        jaysan_model_type.type_name,
        '</p>',
        '<p class=\" m-0 p-0 small \"> Qty :',
        COUNT(*),
        '</p></div><p class=\" m-0 p-0 small text-muted\">',
        pm.sub_type,
        '</p>'
        ) AS product,
        sales_order_form.customer_id,
        (
        SELECT
            CONCAT(
                customer.cus_name,
                ' - ',
                customer.cus_phone
            )
        FROM
            customer
        WHERE
            customer.cus_id = sales_order_form.customer_id
    ) AS customer
FROM
    (
    SELECT
        sales_order_product.opid,
        sales_order_product.oid,
        sales_order_product.type_id,
        sales_order_product.model_id,
        sales_order_product.sub_type,
        sales_order_product.required_qty
    FROM
        `assign_product`
    INNER JOIN sales_order_product ON assign_product.opid = sales_order_product.opid
    WHERE
        1 AND assign_product.assign_type = 'Production' AND dcf_id = 0
) AS pm
INNER JOIN jaysan_product_model ON pm.model_id = jaysan_product_model.model_id
INNER JOIN jaysan_model_type ON pm.type_id = jaysan_model_type.mtid
INNER JOIN sales_order_form ON pm.oid = sales_order_form.oid
GROUP BY
    customer_id,
    opid
) AS assign_data
LEFT JOIN production_modify_approval pma ON
    assign_data.opid = pma.opid
GROUP BY
    assign_data.opid;";

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


