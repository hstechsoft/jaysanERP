-- Active: 1766385460907@@srv1002.hstgr.io@3306@u333142350_jaysan

 
    WITH RECURSIVE bom_hi AS (

        /* ========= Anchor ========= */
        SELECT
            bo.part_id AS output_part,
            bi.bom_in_id as bom_in_id,
            bi.part_id AS input_part,
            bi.qty,
            pt_hi.sub_ass,
            0 AS level,
            bo.component_cat,
         CAST((SELECT part_name FROM parts_tbl WHERE part_id = bo.part_id) AS CHAR) AS path
        FROM bom_output bo
        JOIN bom_input bi ON bo.bom_id = bi.bom_id
        JOIN parts_tbl pt_hi ON bi.part_id = pt_hi.part_id
        WHERE bo.part_id = (
            SELECT part_id
            FROM parts_tbl
            WHERE part_name = '006 Door Assembly 312 SL'
        )
        AND bo.component_cat = 'Door Assy SL 16.5.25'

        UNION ALL

        /* ========= Recursive ========= */
        SELECT
            boc.part_id AS output_part,
            bi.bom_in_id as bom_in_id,  
            bi.part_id AS input_part,
            bi.qty,
            pt.sub_ass,
            h.level + 1,
            boc.component_cat,
        CAST(CONCAT(h.path, '>', (SELECT part_name FROM parts_tbl WHERE part_id = boc.part_id)) AS VARCHAR(500))


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
        p.part_name as paren_part_name,
        c.part_name as child_part_name,
        p.bom_in_id AS parent_bom_in_id,
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
          p.part_name as paren_part_name,
        c.part_name as child_part_name,
        p.bom_in_id ,
        p.qty,
        c.input_part,
        c.qty
    FROM parent_part p
    RIGHT JOIN child_part c
        ON p.input_part = c.input_part

)

SELECT * FROM tb

-- bom_sum as(SELECT bom_hi.*,(SELECT part_name FROM parts_tbl WHERE part_id = input_part) as inpartname, (SELECT part_name FROM parts_tbl WHERE part_id = output_part) as outpartname, 
-- sum(qty) over (PARTITION BY input_part) as total, 
-- sum(if(level = 0, qty, 0)) over (PARTITION BY input_part) as total_level_main,
-- sum(if(level>0, qty, 0)) over (PARTITION BY input_part) as total_level_sub
--  FROM bom_hi ORDER BY level),

--  bom_final as(SELECT path,output_part,input_part,qty,sub_ass,level,outpartname,inpartname,total,total_level_main,total_level_sub,total_level_main-total_level_sub as bal, if(total_level_main<total_level_sub,'sub_excess',if(total_level_main-total_level_sub=0,'no_main','available')) as sts FROM bom_sum )
--  SELECT * FROM bom_final WHERE sts = "available" and level = 0

