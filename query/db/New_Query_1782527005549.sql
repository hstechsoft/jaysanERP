-- Active: 1766385460907@@srv1002.hstgr.io@3306@u333142350_jaysan
WITH RECURSIVE
stock AS (
    SELECT process_id,
           SUM(qty) AS stock_qty
    FROM jaysan_stock
    GROUP BY process_id
),
input_group AS (
    SELECT
    iwp.process_id,
        iwp.previous_process_id,
        s.stock_qty,
       iwp.qty,
        0 AS level
    FROM input_wel_parts iwp
    LEFT JOIN stock s
        ON s.process_id = iwp.previous_process_id
    WHERE iwp.process_id = 2796

    UNION ALL
    SELECT
        child.process_id,
        child.previous_process_id,
        s.stock_qty,
        ig.qty * child.qty,
        ig.level + 1
    FROM input_group ig
    JOIN input_wel_parts child
        ON child.process_id = ig.previous_process_id
    LEFT JOIN stock s
        ON s.process_id = child.previous_process_id
    
)
SELECT input_group.process_id,input_group.previous_process_id as  input_process_id,input_group.stock_qty as input_process_stock_qty,input_group.qty as input_qty_needed,input_group.level, sum(qty) OVER (PARTITION BY previous_process_id ORDER BY LEVEL) as AGGREGATE_input_qty from input_group WHERE input_group.previous_process_id IS NOT NULL order by level