CREATE OR REPLACE VIEW stock_reserve_view_dc AS with
    stock_reserve_exp as (
        select *
        from stock_reserve
        WHERE
            reserve_type not in(
                select reserve_type
                from granted_stock
                where
                    owner = 'transport'
                group by
                    reserve_type
            )
    )
SELECT
    js.part_id,
    js.process_id,
    js.godown,
    js.dep,
    js.sec,
    js.batch_id,
    js.stock_id,
    creditors.creditor_name,
department.dep_name,
dep_section.sec_name,
    js.qty,
    sr.stock_reserve_id,
    sr.reserve_type,
    sr.reserve_type_id,

    sum(sr.reserve_qty) as reserve_qty,
    sum((js.qty - ifnull(sr.available_stock, 0))) as available_stock,
     
   JSON_ARRAYAGG(JSON_OBJECT(
    'document_no', CASE
        WHEN sr.reserve_type = 'dc' THEN dc.dc_no
        -- WHEN sr.reserve_type = 'INVOICE' THEN inv.invoice_no
        ELSE NULL
    END,
    
                    'reserve_qty', sr.reserve_qty,
                    'reserve_status', sr.reserve_status,
                    'reserve_date', sr.dated,
                    'reserve_id', sr.stock_reserve_id
    )) AS reserve_details
from
    jaysan_stock js
    left join stock_reserve_exp sr on js.stock_id = sr.stock_id
    left join creditors on creditors.creditor_id = js.godown
    left join department on department.dep_id = js.dep
    left join dep_section on dep_section.dep_sec_id = js.sec


    LEFT JOIN delivery_challan dc
    ON sr.reserve_type = 'dc'
   AND dc.dc_id = sr.reserve_type_id

-- LEFT JOIN invoice inv
--     ON sr.reserve_type = 'INVOICE'
--    AND inv.invoice_id = sr.reserve_type_id
    group by js.part_id,js.process_id,js.godown,js.dep,js.sec,sr.reserve_type