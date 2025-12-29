  WITH RECURSIVE bom_hierarchy AS (
        -- Base case: top-level parts
        SELECT 
            bom_output.part_id as output_part_id,
            bom_input.bom_in_id,
            bom_input.part_id as input_part_id,
            input_part.part_name,
            bom_input.qty,
            input_part.sub_ass,
            1 as level
        FROM bom_output
        INNER JOIN bom_input ON bom_output.bom_id = bom_input.bom_id
        INNER JOIN parts_tbl ON parts_tbl.part_id = bom_output.part_id
        INNER JOIN parts_tbl as input_part ON input_part.part_id = bom_input.part_id
        WHERE parts_tbl.part_name = "001 Roller Assmbly 312"
        AND bom_output.component_cat = "Roller Assy 12.5.25"
        
        UNION ALL
        
        -- Recursive case: child parts
        SELECT 
            bo.part_id as output_part_id,
            bi.bom_in_id,
            bi.part_id as input_part_id,
            ip.part_name,
            bi.qty * bh.qty as qty,
            ip.sub_ass,
            bh.level + 1
        FROM bom_hierarchy bh
        INNER JOIN bom_output bo ON bh.input_part_id = bo.part_id
        INNER JOIN bom_input bi ON bo.bom_id = bi.bom_id
        INNER JOIN parts_tbl ip ON ip.part_id = bi.part_id
    )
    SELECT * FROM bom_hierarchy WHERE 1;