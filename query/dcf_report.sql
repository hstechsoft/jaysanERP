-- Active: 1766425908618@@srv1002.hstgr.io@3306@u333142350_jaysan
SELECT ap.ass_id,ap.dcf_id,ap.opid,sop.price,sop.required_qty,sp.product as original_qty,dcf.sts,date_only(dcf.dated) as dcf_date,
count(ass_id) as dcf_count FROM assign_product ap
inner join sales_order_product sop on ap.opid = sop.opid
inner join sales_product sp on ap.opid = sp.opid
left join dcf on ap.dcf_id = dcf.dcf_id
 WHERE ap.dcf_id > 0 GROUP BY ap.dcf_id,ap.opid