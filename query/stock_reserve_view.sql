
CREATE OR REPLACE VIEW stock_reserve_view AS with stock_reserved as(SELECT 
js.part_id,
js.process_id,
js.godown,
js.dep,
js.sec,
js.batch_id,
js.stock_id,


sr.reserve_type,
sr.reserve_type_id,
sr.stock_reserve_id,
creditors.creditor_name,
department.dep_name,
dep_section.sec_name,
js.qty as stock_qty,
sum(sr.reserve_qty) as total_reserved_qty,

 
   JSON_ARRAYAGG(JSON_OBJECT(
    'document_no', CASE
        WHEN sr.reserve_type = 'DC' THEN dc.dc_no
        -- WHEN sr.reserve_type = 'INVOICE' THEN inv.invoice_no
        ELSE NULL
    END,
    
                    'reserve_qty', sr.reserve_qty,
                    'reserve_status', sr.reserve_status,
                    'reserve_date', sr.dated,
                    'reserve_id', sr.stock_reserve_id
    )) AS reserve_details
 

 FROM jaysan_stock js  
 LEFT JOIN stock_reserve sr ON sr.stock_id = js.stock_id 
 left join creditors on creditors.creditor_id = js.godown
 left join department on department.dep_id = js.dep
    left join dep_section on dep_section.dep_sec_id = js.sec
   
LEFT JOIN delivery_challan dc
    ON sr.reserve_type = 'dc'
   AND dc.dc_id = sr.reserve_type_id

-- LEFT JOIN invoice inv
--     ON sr.reserve_type = 'INVOICE'
--    AND inv.invoice_id = sr.reserve_type_id


group by js.part_id,js.process_id,js.godown,js.dep,js.sec,sr.reserve_type )



select
    part_id,
    process_id,
    godown,
    dep,
    sec,
    batch_id,
    stock_id,
    
    reserve_type_id,
    stock_reserve_id,
    creditor_name,
    dep_name,
    sec_name,
    stock_qty as qty,
    sum(total_reserved_qty) as reserve_qty,
    stock_qty- sum(ifnull(total_reserved_qty,0)) as available_qty,
    JSON_ARRAYAGG(JSON_OBJECT('reserve_type',reserve_type, 'reserve_details', reserve_details)) as reserve_details

from 
    stock_reserved
GROUP BY
    part_id,
    process_id,
    godown,
    dep,
    sec


 