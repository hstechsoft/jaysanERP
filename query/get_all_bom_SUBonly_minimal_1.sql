-- Active: 1766385460907@@srv1002.hstgr.io@3306@u333142350_jaysan

--  CREATE TEMPORARY TABLE tmp_bom_result AS
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
        WHERE bo.bom_id in (898)
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
    SELECT bom_hi.*,
    outpart.part_name AS outpart_name,
    inpart.part_name AS inpart_name 
    FROM bom_hi 
    inner join parts_tbl inpart on bom_hi.input_part = inpart.part_id
    inner join parts_tbl outpart on bom_hi.output_part = outpart.part_id
    WHERE level = 0 ORDER BY bom_hi.sub_ass DESC
),

child_part AS (
   SELECT bom_hi.*,
outpart.part_name AS outpart_name,
inpart.part_name AS inpart_name
    FROM bom_hi 
    inner join parts_tbl inpart on bom_hi.input_part = inpart.part_id
    inner join parts_tbl outpart on bom_hi.output_part = outpart.part_id
    WHERE level > 0
),

   tb AS (
    /* LEFT side */
    SELECT
    p.outpart_name as parent_outpart_name,
    p.inpart_name as parent_inpart_name,
    c.outpart_name as child_outpart_name,
    c.inpart_name as child_inpart_name,
    p.input_part AS parent_input_part,
        
      
        c.inpart_name as child_part_name,
        p.bom_in_id AS parent_bom_in_id,
        p.qty        AS parent_qty,
        c.input_part AS child_input_part,
        c.qty        AS child_qty,
        c.path
    FROM parent_part p
    LEFT JOIN child_part c
        ON p.input_part = c.input_part

    UNION 

    /* RIGHT side unmatched */
    SELECT
       p.outpart_name as parent_outpart_name,
    p.inpart_name as parent_inpart_name,
    c.outpart_name as child_outpart_name,
    c.inpart_name as child_inpart_name,
        p.input_part,
     
        c.inpart_name as child_part_name,
        p.bom_in_id ,
        p.qty,
        c.input_part,
        c.qty,
        c.path
    FROM parent_part p
    RIGHT JOIN child_part c
        ON p.input_part = c.input_part

)

-- SELECT IFNULL(parent_bom_in_id, 0) AS parent_bom_in_id,
--        child_qty,
    
--        child_input_part
-- FROM tb
-- WHERE child_input_part IS NOT NULL
-- ORDER BY parent_bom_in_id;

-- SELECT * from tmp_bom_result;

-- SELECT parent_bom_in_id,child_qty,parent_bom_in_id,child_input_part FROM tb where child_input_part is not null order by parent_bom_in_id;

 SELECT tb.*,ifnull(parent_qty,0)-ifnull(child_qty,0) as qty_diff,parent_bom_in_id,child_qty,parent_bom_in_id,sum(child_qty ) over (PARTITION BY child_input_part) AS Y FROM tb where child_input_part is not null
-- UPDATE bom_input bi
-- JOIN tmp_bom_result t 
--     ON bi.bom_in_id = t.parent_bom_in_id
-- SET bi.sub_ass_qty = bi.sub_ass_qty +  t.child_qty;




  
