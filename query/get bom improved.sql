
with RECURSIVE bom_hi as(SELECT
    bom_output.bom_id AS parent_bom_id,
    bom_output.component_cat,
    bom_output.part_id AS output_part_id,
    bom_input.part_id AS input_part_id,
    bom_input.qty,
    bom_input.sub_ass_qty,
    out_part.part_name AS output_part_name,
    in_part.part_name AS input_part_name,
   ifnull(bom_correction.bomlist_id,(SELECT bolist.bom_id FROM bom_output bolist WHERE bolist.part_id = bom_input.part_id and bolist.component_cat <> 'Process' and  component_cat <> 'Porcess' LIMIT 1)) as bomlist_id,


       0 as level,
       CAST(bom_output.part_id AS CHAR(2000)) AS path,
       CAST(out_part.part_name  AS CHAR(2000)) AS part_path,
       finished_godown_master.time_taken,
       finished_godown_master.category,
       creditors.creditor_name



FROM bom_output
INNER JOIN bom_input
    ON bom_output.bom_id = bom_input.bom_id
INNER JOIN parts_tbl out_part
    ON out_part.part_id = bom_output.part_id
INNER JOIN parts_tbl in_part
    ON in_part.part_id = bom_input.part_id
LEFT JOIN bom_correction
    ON bom_input.part_id = bom_correction.part_id
   AND bom_correction.outpart_bom_id = 66958 and bom_correction.bom_output_id = bom_output.bom_id
   left join finished_godown_master on finished_godown_master.part_id = in_part.part_id
   LEFT join creditors on creditors.creditor_id = finished_godown_master.godown_id

WHERE bom_output.bom_id = 66958 and in_part.sub_ass = 0
UNION ALL
SELECT 
 bom_output_child.bom_id AS parent_bom_id,
    bom_output_child.component_cat,
    bom_output_child.part_id AS output_part_id,
    bom_input_child.part_id AS input_part_id,
    bom_input_child.qty * bom_hi.qty AS qty,
    bom_input_child.sub_ass_qty * bom_hi.qty AS sub_ass_qty,
    out_part_child.part_name AS output_part_name,
    in_part_child.part_name AS input_part_name,
    ifnull(bom_correction_child.bomlist_id,(SELECT bolist.bom_id FROM bom_output bolist WHERE bolist.part_id = bom_input_child.part_id and bolist.component_cat <> 'Process' and component_cat <> 'Porcess' LIMIT 1)) as bomlist_id,
--    ifnull(bom_correction.bomlist_id,(SELECT bolist.bom_id FROM bom_output bolist WHERE bolist.part_id = bom_input.part_id and bolist.component_cat <> 'Process' and  component_cat <> 'Porcess' LIMIT 1)) as bomlist_id
 
       level +1 as level,
    CONCAT(bom_hi.path, ',', bom_output_child.part_id) AS path,
    CONCAT(bom_hi.part_path, '->', out_part_child.part_name) AS part_path,
    finished_godown_master.time_taken,
       finished_godown_master.category,
       creditors.creditor_name



FROM bom_output bom_output_child
inner join bom_hi on bom_hi.bomlist_id = bom_output_child.bom_id
INNER JOIN bom_input bom_input_child
    ON  bom_output_child.bom_id = bom_input_child.bom_id
INNER JOIN parts_tbl out_part_child
    ON out_part_child.part_id = bom_output_child.part_id
INNER JOIN parts_tbl in_part_child
    ON in_part_child.part_id = bom_input_child.part_id
LEFT JOIN bom_correction bom_correction_child
    ON bom_input_child.part_id = bom_correction_child.part_id
   AND bom_correction_child.outpart_bom_id = 66958 and bom_correction_child.bom_output_id = bom_output_child.bom_id
   left join finished_godown_master on finished_godown_master.part_id = in_part_child.part_id
   LEFT join creditors on creditors.creditor_id = finished_godown_master.godown_id

   WHERE in_part_child.sub_ass = 0)
   SELECT bom_hi.* FROM bom_hi WHERE 1 order by level;