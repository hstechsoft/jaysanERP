-- Active: 1766385460907@@srv1002.hstgr.io@3306@u333142350_jaysan
with cus_product as(SELECT 

     sof.customer_id,
        sum(price) over (PARTITION BY sof.customer_id) as customer_total_product
       
    FROM assign_product ap
    INNER JOIN sales_order_product sop ON ap.opid = sop.opid
    inner join sales_order_form sof on sof.oid = sop.oid
    WHERE ap.dcf_id > 0 ),
    cus_grouped as(
    SELECT customer_total_product,cus_product.customer_id as pcus from cus_product GROUP BY customer_id
    ),
    received_amount as(
    SELECT amount,
    customer_id,
        sum(amount) over (PARTITION BY sof.customer_id) as customer_total_received
    from jaysan_payment  inner join sales_order_form sof on jaysan_payment.oid=sof.oid
    WHERE   sts='approved'
    ),
    received_grouped as(
    SELECT customer_total_received,customer_id as rcus from received_amount GROUP BY customer_id
    )
    SELECT pcus as cus_id,customer_total_product,customer_total_received,customer_total_received-customer_total_product as bal,(SELECT cus_name FROM customer WHERE customer.cus_id = pcus) as cus_name,(SELECT cus_phone FROM customer WHERE customer.cus_id = pcus) as cus_phone FROM cus_grouped cg
    LEFT JOIN received_grouped rg ON pcus =rg.rcus  
    
      
   