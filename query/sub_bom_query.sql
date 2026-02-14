WITH RECURSIVE bom_hi AS (

    /* ========= Anchor query ========= */
    SELECT
        bo.part_id AS output_part,
        bi.part_id AS input_part,
        bi.qty,
        pt_hi.sub_ass,
        0 as level,
        bo.component_cat
        
    FROM bom_output bo
    INNER JOIN bom_input bi
   
        ON bo.bom_id = bi.bom_id
         inner join parts_tbl pt_hi on bi.part_id = pt_hi.part_id
    WHERE bo.part_id = (
            SELECT part_id
            FROM parts_tbl
            WHERE part_name = 'SCALELESS CHAIN FRAME ASSY 3F'
        )
      AND bo.component_cat = (
            SELECT bo1.component_cat
            FROM bom_output bo1
            WHERE bo1.part_id = bo.part_id
              AND bo1.component_cat <> 'Process'
            LIMIT 1
        ) 

    UNION ALL

    /* ========= Recursive query ========= */
    SELECT
        boc.part_id AS output_part,
        bi.part_id AS input_part,
        bi.qty,
     (SELECT sub_ass from parts_tbl WHERE part_id = bi.part_id) as sub_ass,
        h.level + 1 as level,
        boc.component_cat
    FROM bom_output boc

    INNER JOIN bom_hi h ON boc.part_id = h.input_part and h.sub_ass = 1
    INNER JOIN bom_input bi
        ON boc.bom_id = bi.bom_id
    WHERE boc.component_cat = (
            SELECT bo1.component_cat
            FROM bom_output bo1
            WHERE bo1.part_id = boc.part_id
              AND bo1.component_cat <> 'Process'
            LIMIT 1
        ) and boc.part_id != h.output_part and boc.component_cat <> 'Process' 
)

SELECT bom_hi.*, if(input_part=output_part,'duplicate_entry','') as duplicate FROM bom_hi  



