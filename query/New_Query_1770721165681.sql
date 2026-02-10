-- Active: 1766385460907@@srv1002.hstgr.io@3306@u333142350_jaysan
with deliver_amount as (SELECT sum(price) as deliver_amount FROM sales_order_product sop 
inner join assign_product ap on sop.opid = ap.opid
 WHERE sop.oid in (780,767) and ap.dcf_id > 0),

paid_amount as(SELECT sum(amount) as paid_amount from jaysan_payment jp WHERE oid in (780,767) and sts = "approved")

SELECT ifnull((paid_amount.paid_amount-deliver_amount.deliver_amount),0) as balance,deliver_amount,paid_amount from deliver_amount,paid_amount



