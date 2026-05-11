-- Active: 1766385460907@@srv1002.hstgr.io@3306@u333142350_jaysan
SELECT concat(
        '₹', FORMAT(jaysan_payment.amount, 0)
    ) as amount, DATE_FORMAT(
        jaysan_payment.payment_date, '%d-%m-%Y %h:%i %p'
    ) as date_f, jaysan_payment.sts, sales_order_form.order_no,jaysan_payment.ref_no,jaysan_payment.utr_no
from jaysan_payment
    inner JOIN sales_order_form on jaysan_payment.oid = sales_order_form.oid
WHERE
    jaysan_payment.sts = 'approved'
    and sales_order_form.order_no in (460,461)

    UNION ALL


SELECT concat(
        '₹', FORMAT(sale_payment_advance.amount, 0)
    ) as amount, DATE_FORMAT(
        sale_payment_advance.dated, '%d-%m-%Y %h:%i %p'
    ) as date_f, concat('advance taken from - ', sf1.order_no) as sts, sales_order_form.order_no,jaysan_payment.ref_no,jaysan_payment.utr_no
from sale_payment_advance 
    inner JOIN sales_order_form on sale_payment_advance.oid = sales_order_form.oid and advance_ref_id > 0
    inner join sale_payment_advance s1 on sale_payment_advance.advance_ref_id = s1.advance_id
      inner join jaysan_payment on s1.payment_id = jaysan_payment.payment_id
    inner join sales_order_form sf1 on s1.oid = sf1.oid 
  
WHERE
   
     sales_order_form.order_no in (460,461)
