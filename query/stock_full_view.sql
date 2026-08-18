CREATE OR REPLACE VIEW stock_full_view AS
WITH reserve AS (
    SELECT 
        js.*,
        CASE 
            WHEN COUNT(sr.stock_id) = 0 THEN JSON_ARRAY()
            ELSE JSON_ARRAYAGG(
                JSON_OBJECT(
                    'reserve_type', sr.reserve_type,
                    'reserve_qty', sr.reserve_qty
                )
            )
        END AS reserves,
        SUM(IFNULL(js.qty, 0)) - SUM(IFNULL(sr.reserve_qty, 0)) AS available_qty
    FROM jaysan_stock js
    LEFT JOIN stock_reserve sr 
        ON js.stock_id = sr.stock_id
    GROUP BY js.stock_id
)
SELECT 
    reserve.*,
    parts_tbl.part_name,
    godown.creditor_name AS godown_name,
    dep.dep_name,
    sec.sec_name
FROM reserve
LEFT JOIN parts_tbl 
    ON reserve.part_id = parts_tbl.part_id
LEFT JOIN creditors godown 
    ON godown.creditor_id = reserve.godown
LEFT JOIN department dep 
    ON dep.dep_id = reserve.dep
LEFT JOIN dep_section sec 
    ON sec.dep_sec_id = reserve.sec;