-- Active: 1766385460907@@srv1002.hstgr.io@3306@u333142350_jaysan
SELECT 
        parts_tbl.part_name,
        DATE_FORMAT(mrf.dated, '%d-%m-%Y') AS dated,
         DATE_FORMAT(mrf.last_purchase_date, '%d-%m-%Y') AS last_purchase_date,
        employee.emp_name,
        DATE_FORMAT(mrf.req_date, '%d-%m-%Y') AS req_date,
        mrf.req_qty,
        mrf.uom mrf_uom,
        mrf.stock_for_sufficent_days,
        mrf.shortfall_qty,
        mrf.order_type,
        mrf.part_id,
        mrf_purchase.*,
         (SELECT creditors.creditor_name from creditors WHERE creditors.creditor_id = mrf_purchase.order_to) as order_to_name,
        (SELECT creditors.creditor_name from creditors WHERE creditors.creditor_id = mrf_purchase.delivery_to) as deliver_to_name,
        (SELECT parts_tbl.part_name from parts_tbl WHERE parts_tbl.part_id = mrf_purchase.raw_material_part_id) as raw_material
    FROM material_request_form mrf
    INNER JOIN parts_tbl ON mrf.part_id = parts_tbl.part_id
        INNER JOIN employee ON mrf.prepared_by = employee.emp_id
        left join mrf_purchase on mrf.mrf_id = mrf_purchase.mrf_id
        
    WHERE mrf.mrf_id =  1079 ORDER BY part_name, dated DESC;