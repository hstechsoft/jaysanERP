
 with ass_pro as  (SELECT ap.dcf_id,ap.opid,sop.price,sp.product,sof.order_no,sof.customer_id,COUNT(ap.dcf_id) as delivery_count,COUNT(ap.dcf_id)*sop.price as delivered_amount FROM assign_product ap  
INNER join sales_order_product sop on ap.opid = sop.opid
INNER join sales_product sp on ap.opid = sp.opid
inner join sales_order_form sof on sop.oid = sof.oid
WHERE sof.customer_id = 152 and ap.dcf_id > 0 GROUP BY ap.opid,ap.dcf_id),
ass_pro_final as (SELECT * FROM ass_pro GROUP BY dcf_id),
spares as (SELECT sum(sos.amount) as total_sapares,sos.dcf_no as dcf_id, sos.amount,sos.qno,sof.customer_id,sof.oid FROM sale_order_spares sos
inner join sales_order_form sof on sos.oid = sof.oid
 WHERE dcf_no > 0 and sof.customer_id = 152 GROUP BY dcf_id)




SELECT date_only(dcf.dated) as dcf_date,dcf.sts as dcf_sts,ass_pro_final.product,order_no,delivery_count,delivered_amount,spares.amount,spares.qno
 FROM dcf

 LEFT  join ass_pro_final on dcf.dcf_id = ass_pro_final.dcf_id 
 left join spares on dcf.dcf_id = spares.dcf_id WHERE delivery_count is not null or amount is not null LIMIT 500