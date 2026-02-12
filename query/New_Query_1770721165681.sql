with RECURSIVE bom_hi as( SELECT
    bom_output.bom_id as parent_bom_id,
    bom_output.component_cat,
    bom_output.part_id as output_part_id,
    bom_input.part_id as input_part_id,
    bom_input.qty,
    out_part.part_name as output_part_name,
    in_part.part_name as input_part_name,
    0 as level,
    (SELECT COUNT(bom_id) from bom_output bo WHERE bo.part_id = bom_input.part_id and bo.component_cat <> "Process") as total_bom_count,
     (SELECT JSON_ARRAYAGG(JSON_OBJECT('bom_id',bo1.bom_id,'component_cat',bo1.component_cat)) from bom_output bo1 WHERE bo1.part_id = bom_input.part_id and bo1.component_cat <> "Process" GROUP BY bo1.part_id) as total_bom_count
FROM
    bom_output
    INNER join bom_input on bom_output.bom_id = bom_input.bom_id
    inner join parts_tbl out_part on out_part.part_id = bom_output.part_id
    inner join parts_tbl in_part on in_part.part_id = bom_input.part_id
WHERE
    bom_output.bom_id = 10

UNION all 
SELECT 

)