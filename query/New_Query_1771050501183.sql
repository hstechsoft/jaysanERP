WITH RECURSIVE bom_process AS (

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
ON bom_process.previous_process_id = pwt.process_id
),

bom_master as (SELECT 

bp.process_id,
jaysan_process.process_name,
JSON_ARRAYAGG(JSON_OBJECT('input_part_id',input_part_id,'part_name',pt.part_name,'input_qty',iwp.qty)) AS input_parts,
wtm.wtid,
JSON_ARRAYAGG(JSON_OBJECT(

'min_time',wtm.min_time,
'max_time',wtm.max_time,
'cost',wtm.cost,
'dep_id',wtm.dep_id,
'dep_sec_id',wtm.dep_sec_id,
'godown_id',wtm.godown_id,
'machine_id',wtm.machine_id,
'creditor_name',creditors.creditor_name,
'dep_name',department.dep_name,
'sec_name',dep_section.sec_name,
'machine_name',dep_sec_machine.machine_name)) as extra_details


FROM bom_process bp
LEFT JOIN input_wel_parts iwp

ON bp.process_id = iwp.process_id
LEFT join parts_tbl pt on iwp.input_part_id = pt.part_id 
left join work_time_master wtm on bp.process_id = wtm.ori_process_id
left join creditors on creditors.creditor_id = wtm.godown_id
LEFT join department on department.dep_id = wtm.dep_id
LEFT join dep_section on dep_section.dep_sec_id = wtm.dep_sec_id
LEFT join dep_sec_machine on dep_sec_machine.dep_sec_machine_id = wtm.machine_id
LEFT join jaysan_process on jaysan_process.process_id = bp.process_id


WHERE input_part_id > 0 GROUP BY process_id,wtid
ORDER BY bp.level DESC )

SELECT * FROM bom_master GROUP BY process_id;