WITH RECURSIVE bom_hi AS (

    /* ========= Anchor query ========= */
    SELECT
        bo.part_id AS output_part,
        bi.part_id AS input_part,
        0 as level,
        bo.component_cat
        
    FROM bom_output bo
    INNER JOIN bom_input bi
        ON bo.bom_id = bi.bom_id
    WHERE bo.part_id = (
            SELECT part_id
            FROM parts_tbl
            WHERE part_name = 'JRB 310 Round Baler 4g Scaleless Bush Type WOD'
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
        h.level + 1 as level,
        boc.component_cat
    FROM bom_output boc
    INNER JOIN bom_hi h
        ON boc.part_id = h.input_part 
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

SELECT bom_hi.*,if(input_part=output_part,'duplicate_entry','') as duplicate, ROW_NUMBER() OVER () as row_num FROM bom_hi  


