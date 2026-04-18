WITH RECURSIVE process_flow AS (

    -- 🔹 Anchor
    SELECT 
    p.final_process_id,
        p.process_id,
        p.output_part,
        i.input_part_id,
        i.previous_process_id,
        i.qty,
        p.process,
        0 AS level,
        CAST(p.process_id AS CHAR(200)) AS path,
        0 AS is_cycle
    FROM process_wel_tbl p
    JOIN input_wel_parts i 
        ON p.process_id = i.process_id
    WHERE p.process_id = 2796

    UNION ALL

    -- 🔹 Recursive
    SELECT 
    p2.final_process_id,
        p2.process_id,
        p2.output_part,
        i2.input_part_id,
        i2.previous_process_id,
        i2.qty,
        p2.process,
        pf.level + 1,
        CONCAT(pf.path, '->', p2.process_id),

        -- 🔥 Detect cycle
        CASE 
            WHEN FIND_IN_SET(p2.process_id, REPLACE(pf.path, '->', ',')) > 0 
            THEN 1 
            ELSE 0 
        END AS is_cycle

    FROM process_flow pf
    JOIN process_wel_tbl p2 
        ON p2.process_id = pf.previous_process_id
    JOIN input_wel_parts i2 
        ON p2.process_id = i2.process_id

    WHERE pf.previous_process_id IS NOT NULL
      AND pf.level < 20

      -- 🔥 Stop recursion ONLY if already cycle before
      AND pf.is_cycle = 0
),

input_group as(SELECT pf.final_process_id, pf.process_id,pf.output_part,pf.input_part_id, pt.part_name AS input_part_name,pf.previous_process_id, jp_in.process_name AS previous_process_name, pf.qty,pf.pr  ocess,jp.process_name AS process_name,pf.level,pf.path  FROM process_flow pf
LEFT JOIN parts_tbl pt ON pf.input_part_id = pt.part_id

left join jaysan_process jp on jp.process_id = pf.process
left join process_wel_tbl pwl_in on pf.previous_process_id = pwl_in.process_id
left join jaysan_process jp_in on jp_in.process_id = pwl_in.process
ORDER BY level),



-- input_group as(SELECT pf.final_process_id, pf.process_id,pf.output_part,pt2.part_name AS output_part_name,pf.input_part_id, pt.part_name AS input_part_name,pf.previous_process_id, jp_in.process_name AS previous_process_name, pf.qty,pf.process,jp.process_name AS process_name,pf.level,pf.path  FROM process_flow pf
-- LEFT JOIN parts_tbl pt ON pf.input_part_id = pt.part_id
-- LEFT JOIN parts_tbl pt2 ON pf.output_part = pt2.part_id 
-- left join jaysan_process jp on jp.process_id = pf.process
-- left join process_wel_tbl pwl_in on pf.previous_process_id = pwl_in.process_id
-- left join jaysan_process jp_in on jp_in.process_id = pwl_in.process
-- ORDER BY level),

process_group AS (
SELECT input_group.process_id,input_group.final_process_id, input_group.output_part,COALESCE(input_group.output_part_name, CONCAT('semi finished part - ' , final_part.part_name,'(IN -', input_group.process_name, ')'))  as output_part_name, COALESCE(input_group.input_part_id,final_wel.output_part) as input_part_id,  COALESCE(input_group.input_part_name,CONCAT('semi finished part - ' , final_part.part_name,'(from -', input_group.previous_process_name, ')')) as input_part_name, sum(input_group.qty) as qty, input_group.previous_process_id,  input_group.previous_process_name,input_group.process,input_group.process_name,input_group.level,input_group.path FROM input_group  
left join process_wel_tbl final_wel on final_wel.process_id = input_group.final_process_id
left join parts_tbl final_part on final_part.part_id = final_wel.output_part

GROUP BY input_group.process_id,COALESCE(input_group.input_part_id,final_wel.output_part)
order by input_group.final_process_id ),
input_group_final AS (
    SELECT process_group.process_id,process_group.final_process_id, process_group.output_part,process_group.output_part_name,process_group.input_part_id,process_group.input_part_name,sum(process_group.qty) as qty,process_group.previous_process_id,  process_group.previous_process_name,process_group.process,process_group.process_name,process_group.level,process_group.path FROM process_group GROUP BY input_part_id,previous_process_id)

SELECT input_group_final.process_id,final_process_id,output_part,output_part_name,input_part_id,input_part_name,qty, wtm.min_time, wtm.max_time, wtm.cost, creditors.creditor_name, department.dep_name, dep_section.sec_name FROM input_group_final
left join work_time_master wtm on wtm.ori_process_id = input_group_final.previous_process_id
left join creditors on wtm.godown_id = creditors.creditor_id
left join department on wtm.dep_id = department.dep_id
left join dep_section on wtm.dep_sec_id = dep_section.dep_sec_id
