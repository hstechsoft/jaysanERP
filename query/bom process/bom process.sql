WITH RECURSIVE process_flow AS (

    -- 🔹 Anchor
    SELECT 
        p.process_id,
        p.output_part,
        i.input_part_id,
        i.previous_process_id,
        i.qty,
        0 AS level,
        CAST(p.process_id AS CHAR(200)) AS path,
        0 AS is_cycle
    FROM process_wel_tbl p
    JOIN input_wel_parts i 
        ON p.process_id = i.process_id
    WHERE p.process_id = 2796

    UNION ALL

    -- 🔹 Recursive
    SELECT 
        p2.process_id,
        p2.output_part,
        i2.input_part_id,
        i2.previous_process_id,
        i2.qty,
        pf.level + 1,
        CONCAT(pf.path, '->', p2.process_id),

        -- 🔥 Detect cycle
        CASE 
            WHEN FIND_IN_SET(p2.process_id, REPLACE(pf.path, '->', ',')) > 0 
            THEN 1 
            ELSE 0 
        END AS is_cycle

    FROM process_flow pf
    JOIN process_wel_tbl p2 
        ON p2.process_id = pf.previous_process_id
    JOIN input_wel_parts i2 
        ON p2.process_id = i2.process_id

    WHERE pf.previous_process_id IS NOT NULL
      AND pf.level < 20

      -- 🔥 Stop recursion ONLY if already cycle before
      AND pf.is_cycle = 0
)

SELECT pf.*, pt.part_name AS input_part_name, pt2.part_name AS output_part_name FROM process_flow pf
LEFT JOIN parts_tbl pt ON pf.input_part_id = pt.part_id
LEFT JOIN parts_tbl pt2 ON pf.output_part = pt2.part_id 
ORDER BY level, process_id;