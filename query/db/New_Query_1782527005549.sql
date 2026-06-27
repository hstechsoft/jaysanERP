-- Active: 1766425908618@@srv1002.hstgr.io@3306@u333142350_jaysan
WITH RECURSIVE
stock AS (
    SELECT process_id,
           SUM(qty) AS stock_qty
    FROM jaysan_stock
    GROUP BY process_id
),
input_group AS (

    -- Anchor
    SELECT
        iwp.previous_process_id,
        (60 * iwp.qty) AS required_qty,
        GREATEST((60 * iwp.qty) - IFNULL(s.stock_qty,0),0) AS produce_qty,
        0 AS level
    FROM input_wel_parts iwp
    LEFT JOIN stock s
        ON s.process_id = iwp.previous_process_id
    WHERE iwp.process_id = 2796

    UNION ALL

    -- Recursive
    SELECT
        child.previous_process_id,
        ig.produce_qty * child.qty AS required_qty,
        GREATEST(
            (ig.produce_qty * child.qty) - IFNULL(s.stock_qty,0),
            0
        ) AS produce_qty,
        ig.level + 1
    FROM input_group ig
    JOIN input_wel_parts child
        ON child.process_id = ig.previous_process_id
    LEFT JOIN stock s
        ON s.process_id = child.previous_process_id
    WHERE ig.produce_qty > 0
)

SELECT *
FROM input_group;E