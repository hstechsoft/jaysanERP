-- Active: 1766425908618@@srv1002.hstgr.io@3306@u333142350_jaysan
with ass_pro as (SELECT ap.dcf_id,ap.opid,sop.price,sop.required_qty,sp.product as product,dcf.sts,date_only(dcf.dated) as dcf_date,ass_id FROM assign_product ap
inner join sales_order_product sop on ap.opid = sop.opid
inner join sales_product sp on ap.opid = sp.opid
inner join dcf on ap.dcf_id = dcf.dcf_id
inner join sales_order_form sof on sop.oid = sof.oid
 WHERE ap.dcf_id > 0 and sof.customer_id = 33),
 ass_pro1 as(SELECT dcf_id,opid,price,required_qty,product ,sts, dcf_date,
count(ass_id) as dcf_count,count(ass_id) * price as delivered_amount FROM ass_pro 
 GROUP BY dcf_id,opid),
 ass_pro_final as (SELECT JSON_ARRAYAGG(JSON_OBJECT('product',product,'price',price,'delivered_qty',dcf_count,'delivered_amount',delivered_amount)) as products, dcf_id,opid, sum(dcf_count) as total_dcf_count, sum(delivered_amount) as total_delivered_amount, sts, dcf_date FROM ass_pro1 GROUP BY dcf_id), 
 spares_dcf as (SELECT sos.oid, sum(sos.amount) as total_spares_amount,sos.dcf_no as dcf_id,dcf.sts as dcf_sts,date_only(dcf.dated) as dcf_date , JSON_ARRAYAGG(JSON_OBJECT('qno',qno,'oid',sos.oid,'spares_amount',sos.amount)) as spares  FROM sale_order_spares sos INNER join dcf on sos.dcf_no = dcf.dcf_id 
 inner join sales_order_form sof on sos.oid = sof.oid
 WHERE dcf_no > 0 and sof.customer_id = 33 GROUP BY dcf_id)
 SELECT products,spares,ass_pro_final.dcf_id,total_dcf_count as total_product_deleliverd,total_delivered_amount as total_delivered_amount_product,sts,ass_pro_final.dcf_date,total_spares_amount FROM ass_pro_final LEFT join  spares_dcf on ass_pro_final.dcf_id = spares_dcf.dcf_id
 UNION all 
 SELECT JSON_ARRAYAGG(JSON_OBJECT('product','null')) as products,JSON_ARRAYAGG(JSON_OBJECT('qno',qno,'oid',oid,'spares_amount',sos.amount)) as spares,dcf_id,0,0,sts,sos.dated,0  FROM sale_order_spares sos INNER join dcf on sos.dcf_no = dcf.dcf_id WHERE sos.dcf_no > 0 and dcf_no not in(SELECT dcf_id FROM assign_product WHERE dcf_id>0) GROUP BY dcf_id