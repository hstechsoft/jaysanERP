
 
    WITH RECURSIVE bom_hi AS (

        /* ========= Anchor ========= */
        SELECT
            bo.part_id AS output_part,
            bi.part_id AS input_part,
            bi.qty,
            pt_hi.sub_ass,
            0 AS level,
            bo.component_cat
        FROM bom_output bo
        JOIN bom_input bi ON bo.bom_id = bi.bom_id
        JOIN parts_tbl pt_hi ON bi.part_id = pt_hi.part_id
        WHERE bo.part_id = (
            SELECT part_id
            FROM parts_tbl
            WHERE part_name = '001 Roller Ass 310'
        )
        AND bo.component_cat = 'Roller Assy 10.5.2025'

        UNION ALL

        /* ========= Recursive ========= */
        SELECT
            boc.part_id AS output_part,
            bi.part_id AS input_part,
            bi.qty,
            pt.sub_ass,
            h.level + 1,
            boc.component_cat
        FROM bom_output boc
        JOIN bom_hi h
            ON boc.part_id = h.input_part
        AND h.sub_ass = 1
        JOIN bom_input bi ON boc.bom_id = bi.bom_id
        JOIN parts_tbl pt ON bi.part_id = pt.part_id
        WHERE boc.component_cat <> 'Process'
        AND boc.part_id <> h.output_part
    ),
    parent_part AS (
    SELECT bom_hi.*,parts_tbl.part_name
    FROM bom_hi inner join parts_tbl on bom_hi.input_part = parts_tbl.part_id
    WHERE level = 0 ORDER BY bom_hi.sub_ass DESC
),

child_part AS (
   SELECT bom_hi.*,parts_tbl.part_name
    FROM bom_hi inner join parts_tbl on bom_hi.input_part = parts_tbl.part_id
    WHERE level > 0
),

   tb AS (
    /* LEFT side */
    SELECT
        p.input_part AS parent_input_part,
        p.qty        AS parent_qty,
        c.input_part AS child_input_part,
        c.qty        AS child_qty
    FROM parent_part p
    LEFT JOIN child_part c
        ON p.input_part = c.input_part

    UNION 

    /* RIGHT side unmatched */
    SELECT
        p.input_part,
        p.qty,
        c.input_part,
        c.qty
    FROM parent_part p
    RIGHT JOIN child_part c
        ON p.input_part = c.input_part

)

SELECT bom_hi.*,(SELECT part_name FROM parts_tbl WHERE part_id = input_part) as partname, 
sum(qty) over (PARTITION BY input_part) as total, 
sum(if(level = 0, qty, 0)) over (PARTITION BY input_part) as total_level_main,
sum(if(level>0, qty, 0)) over (PARTITION BY input_part) as total_level_sub
 FROM bom_hi ORDER BY level;

