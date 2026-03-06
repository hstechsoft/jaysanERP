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
       CAST(out_part.part_name  AS CHAR(2000)) AS part_path
      



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
    CONCAT(bom_hi.part_path, '->', out_part_child.part_name) AS part_path
   


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
  WHERE in_part_child.sub_ass = 0),

   bom_input_result as (SELECT output_part_id, output_part_name,component_cat FROM bom_hi WHERE 1 GROUP BY output_part_id ),
   
   bom_process as (
SELECT
 output_part,
 process_id,
 process,
 previous_process_id,
 cat,
 0 AS level
FROM process_wel_tbl
WHERE component_cat = "Welding Main Roller 30 Dia"
AND output_part = '302'
AND cat = 'out'

UNION ALL

SELECT
 pwt.output_part,
 pwt.process_id,
 pwt.process,
 pwt.previous_process_id,
 pwt.cat,
 bom_process.level + 1
FROM bom_process
JOIN process_wel_tbl pwt
ON bom_process.previous_process_id = pwt.process_id),

bom_master as (SELECT 
wtm.min_time,
wtm.max_time,
wtm.cost,
wtm.dep_id,
wtm.dep_sec_id,
wtm.godown_id,
wtm.machine_id,
creditors.creditor_name,
department.dep_name,
dep_section.sec_name,
dep_sec_machine.machine_name,
bp.process_id,
jaysan_process.process_name,
JSON_ARRAYAGG(JSON_OBJECT('input_part_id',input_part_id,'part_name',pt.part_name,'input_qty',iwp.qty)) AS input_parts,
wtm.wtid



FROM bom_process bp
LEFT JOIN input_wel_parts iwp

ON bp.process_id = iwp.process_id
LEFT join parts_tbl pt on iwp.input_part_id = pt.part_id 
left join work_time_master wtm on bp.process_id = wtm.ori_process_id 
left join creditors on creditors.creditor_id = wtm.godown_id
LEFT join department on department.dep_id = wtm.dep_id      
LEFT join dep_section on dep_section.dep_sec_id = wtm.dep_sec_id
LEFT join dep_sec_machine on dep_sec_machine.dep_sec_machine_id = wtm.machine_id
LEFT join jaysan_process on jaysan_process.process_id = bp. process


WHERE input_part_id > 0 GROUP BY process_id,wtid
ORDER BY bp.level DESC ),

extra as (SELECT min_time,max_time,cost,dep_id,dep_sec_id,godown_id,machine_id,creditor_name,dep_name,sec_name,machine_name,process_id,input_parts,process_name,
JSON_ARRAYAGG(JSON_OBJECT(
'wtid',wtid,
'min_time',min_time,
'max_time',max_time,
'cost',cost,
'dep_id',dep_id,
'dep_sec_id',dep_sec_id,
'godown_id',godown_id,
'machine_id',machine_id,
'creditor_name',creditor_name,
'dep_name',dep_name,
'sec_name',sec_name,
'machine_name',machine_name)) as extra_details FROM bom_master GROUP BY process_id)

 SELECT * FROM bom_input_result;
-- SELECT * FROM extra
   


   