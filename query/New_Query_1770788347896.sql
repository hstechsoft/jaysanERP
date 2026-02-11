-- Active: 1766385460907@@srv1002.hstgr.io@3306@u333142350_jaysan
SELECT JSON_ARRAYAGG(JSON_OBJECT('po_id', jpm.jaysan_po_id, 'qty', jpm.qty,'po_no',(SELECT po_no FROM jaysan_po WHERE jaysan_po.po_id = jpm.jaysan_po_id),'po_date',(SELECT date_only(po_date) FROM jaysan_po WHERE jaysan_po.po_id = jpm.jaysan_po_id))) AS po_details, mrf.mrf_id, date_only(mrf_batch.batch_date) as batch_date, mrf_batch.batch_qty, mrf_batch.po_date,sum(jpm.qty) as total_po_qty FROM mrf_batch
inner join material_request_form mrf on mrf_batch.mrf_id = mrf.mrf_id
LEFT join jaysan_po_material jpm on jpm.batch_id = mrf_batch.batch_id GROUP BY mrf_batch.batch_id order by jaysan_po_id asc 


with grn_details as (SELECT JSON_ARRAYAGG(JSON_OBJECT('grn_date', date_only(grn.dc_date), 'grn_no', grn.dc_no, 'received_qty', grn.qty)) AS grn_details,sum(grn.qty) as total_received_qty, jpm.batch_id, jpm.jaysan_po_material_id, jpm.qty as actual_po_qty, po.po_no, date_only(po.po_date) as po_created_date FROM jaysan_po_material jpm 
inner join jaysan_po po  on jpm.jaysan_po_id = po.po_id 
left join grn on jpm.jaysan_po_material_id = grn.jaysan_po_material_id  GROUP BY jpm.jaysan_po_material_id ),
batch_details as(SELECT sum(total_received_qty) as batch_receive_qty, sum(actual_po_qty) as batch_po_qty, JSON_ARRAYAGG(JSON_OBJECT('grn_details', grn_details, 'total_received_qty', total_received_qty,  'actual_po_qty', actual_po_qty, 'po_no', po_no, 'po_created_date', po_created_date)) as po_details, mrf_batch.batch_id ,date_only(mrf_batch.batch_date) as batch_date,mrf_batch.batch_qty ,mrf_batch.mrf_id FROM mrf_batch LEFT join grn_details on mrf_batch.batch_id = grn_details.batch_id GROUP BY mrf_batch.batch_id)
SELECT  sum(batch_receive_qty) as mrf_receive_qty, sum(batch_po_qty) as mrf_po_qty,sum(batch_qty) as mrf_batch_qty,JSON_ARRAYAGG(JSON_OBJECT('batch_id', batch_id, 'batch_date', batch_date, 'batch_qty', batch_qty, 'po_details', po_details)) as batch_details,mrf_id from batch_details GROUP BY mrf_id


