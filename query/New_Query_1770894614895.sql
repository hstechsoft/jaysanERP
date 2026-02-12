SELECT
    bom_output.bom_id AS parent_bom_id,
    bom_output.component_cat,
    bom_output.part_id AS output_part_id,
    bom_input.part_id AS input_part_id,
    bom_input.qty,
    out_part.part_name AS output_part_name,
    in_part.part_name AS input_part_name,
    bom_correction.bomlist_id,

    IF(
        bom_correction.bomlist_id IS NULL,
        IF(
            (SELECT COUNT(bo.bom_id)
             FROM bom_output bo
             WHERE bo.part_id = bom_input.part_id
               AND bo.component_cat <> 'Process'
            ) > 1,
            'invalid',
            'valid'
        ),
        'valid'
    ) AS correction_status,
       (SELECT JSON_ARRAYAGG(JSON_OBJECT('bom_id',bo1.bom_id,'component_cat',bo1.component_cat)) from bom_output bo1 WHERE bo1.part_id = bom_input.part_id and bo1.component_cat <> "Process" GROUP BY bo1.part_id having count(bo1.part_id)>1) as bom_list



FROM bom_output
INNER JOIN bom_input
    ON bom_output.bom_id = bom_input.bom_id
INNER JOIN parts_tbl out_part
    ON out_part.part_id = bom_output.part_id
INNER JOIN parts_tbl in_part
    ON in_part.part_id = bom_input.part_id
LEFT JOIN bom_correction
    ON bom_input.part_id = bom_correction.part_id
   AND bom_correction.outpart_bom_id = 10

WHERE bom_output.bom_id = 10;