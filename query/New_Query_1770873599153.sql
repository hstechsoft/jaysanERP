-- Active: 1766385460907@@srv1002.hstgr.io@3306@u333142350_jaysan
with RECURSIVE bom_hi as( SELECT
    bom_output.bom_id as parent_bom_id,
    bom_output.component_cat,
    bom_output.part_id as output_part_id,
    bom_input.part_id as input_part_id, 
    bom_input.qty,
    out_part.part_name as output_part_name,
    in_part.part_name as input_part_name,
      (SELECT COUNT(bom_id) from bom_output bo WHERE bo.part_id = bom_input.part_id and bo.component_cat <> "Process") as total_bom_count,
     (SELECT JSON_ARRAYAGG(JSON_OBJECT('bom_id',bo1.bom_id,'component_cat',bo1.component_cat)) from bom_output bo1 WHERE bo1.part_id = bom_input.part_id and bo1.component_cat <> "Process" GROUP BY bo1.part_id) as bom_list,
    0 as level 
   FROM
    bom_output
    INNER join bom_input on bom_output.bom_id = bom_input.bom_id
    inner join parts_tbl out_part on out_part.part_id = bom_output.part_id
    inner join parts_tbl in_part on in_part.part_id = bom_input.part_id
WHERE
    bom_output.bom_id = 10

UNION all 
SELECT   
 bom_output_child.bom_id as parent_bom_id,
    bom_output_child.component_cat,
    bom_output_child.part_id as output_part_id,
    bom_input_child.part_id as input_part_id,
    bom_input_child.qty,
    out_part_child.part_name as output_part_name,
    in_part_child.part_name as input_part_name,
     (SELECT COUNT(bom_id) from bom_output bo WHERE bo.part_id = bom_output_child.part_id and bo.component_cat <> "Process") as total_bom_count,
     (SELECT JSON_ARRAYAGG(JSON_OBJECT('bom_id',bo1.bom_id,'component_cat',bo1.component_cat)) from bom_output bo1 WHERE bo1.part_id = bom_output_child.part_id and bo1.component_cat <> "Process" GROUP BY bo1.part_id) as bom_list,
     level+1 as level from bom_output bom_output_child
inner join bom_input bom_input_child on bom_output_child.bom_id = bom_input_child.bom_id
INNER join parts_tbl out_part_child on out_part_child.part_id = bom_output_child.part_id
INNER join parts_tbl in_part_child on in_part_child.part_id = bom_input_child.part_id
inner join bom_hi on bom_hi.input_part_id = bom_output_child.part_id 
WHERE  bom_output_child.component_cat <> "Process" AND (
     SELECT COUNT(*)
     FROM bom_output bo_chk
     WHERE bo_chk.part_id = bom_hi.input_part_id
       AND bo_chk.component_cat <> 'Process'
) <= 1
)

SELECT bom_hi.*FROM bom_hi 
