-- Active: 1766425908618@@srv1002.hstgr.io@3306@u333142350_jaysan


with advance_master as(SELECT amount,advance_id,payment_id FROM `sale_payment_advance` WHERE advance_ref_id is null and cus_id = 152),
advance_child as (SELECT sum(amount) as total_amount,advance_ref_id,payment_id from sale_payment_advance WHERE advance_ref_id is NOT null and cus_id = 152 GROUP by advance_ref_id),

advance as(SELECT am.amount,am.advance_id,ac.total_amount, am.amount-ifnull(ac.total_amount,0) as balance_amount,am.payment_id FROM advance_master am
LEFT JOIN advance_child ac on am.advance_id = ac.advance_ref_id)

SELECT advance.*,jp.payment_date,jp.ref_no,jp.utr_no  FROM advance  advance inner join jaysan_payment jp on advance.payment_id = jp.payment_id WHERE  advance.balance_amount > 0;



SELECT DISTINCT sum(jaysan_paymentamount),jaysan_payment.oid,sum(sales_order_product.price) as product_amount,sum(sale_order_spares.amount) as spares_amount from jaysan_payment 
left join sales_order_product on jaysan_payment.oid = sales_order_product.oid
LEFT join sale_order_spares on jaysan_payment.oid = sale_order_spares.oid
 WHERE jaysan_payment.oid = 317 GROUP BY jaysan_payment.oid;

SELECT * FROM sales_order_product WHERE oid = 317;

with advance as( SELECT jaysan_payment.payment_id, jaysan_payment.amount ,jaysan_payment.oid,sales_order_product.price,sale_order_spares.amount from jaysan_payment 
left join sales_order_product on jaysan_payment.oid = sales_order_product.oid
LEFT join sale_order_spares on jaysan_payment.oid = sale_order_spares.oid
 WHERE jaysan_payment.oid = 317 )
    SELECT* from advance

