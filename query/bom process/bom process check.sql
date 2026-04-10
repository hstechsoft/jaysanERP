WITH RECURSIVE process_check AS (

    -- 🔹 Start from ALL processes 
    SELECT 
        p.process_id AS start_process,
        p.process_id,
        i.previous_process_id,
        CAST(p.process_id AS CHAR(200)) AS path,
        0 AS is_cycle
    FROM process_wel_tbl p
    JOIN input_wel_parts i 
        ON p.process_id = i.process_id

    UNION ALL

    -- 🔹 Recursive traversal
    SELECT 
        pc.start_process,
        p2.process_id,
        i2.previous_process_id,
        CONCAT(pc.path, '->', p2.process_id),

        -- 🔥 Detect cycle
        CASE 
            WHEN FIND_IN_SET(p2.process_id, REPLACE(pc.path, '->', ',')) > 0 
            THEN 1 
            ELSE 0 
        END AS is_cycle

    FROM process_check pc
    JOIN process_wel_tbl p2 
        ON p2.process_id = pc.previous_process_id
    JOIN input_wel_parts i2 
        ON p2.process_id = i2.process_id

    WHERE pc.previous_process_id IS NOT NULL
      AND pc.is_cycle = 0
      AND LENGTH(pc.path) < 200   -- safety
)

-- 🔥 Final: Only cycles
SELECT 
    start_process,
    process_id AS loop_at,
    path
FROM process_check
WHERE is_cycle = 1;