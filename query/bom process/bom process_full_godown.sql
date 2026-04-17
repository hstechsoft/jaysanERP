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

input_group as(SELECT pf.final_process_id, pf.process_id,pf.output_part,pt2.part_name AS output_part_name,pf.input_part_id, pt.part_name AS input_part_name,pf.previous_process_id, jp_in.process_name AS previous_process_name, pf.qty,pf.process,jp.process_name AS process_name,pf.level,pf.path  FROM process_flow pf
LEFT JOIN parts_tbl pt ON pf.input_part_id = pt.part_id
LEFT JOIN parts_tbl pt2 ON pf.output_part = pt2.part_id 
left join jaysan_process jp on jp.process_id = pf.process
left join process_wel_tbl pwl_in on pf.previous_process_id = pwl_in.process_id
left join jaysan_process jp_in on jp_in.process_id = pwl_in.process
ORDER BY level),

process_group AS (
SELECT input_group.process_id,input_group.final_process_id, input_group.output_part,COALESCE(input_group.output_part_name, CONCAT('semi finished part - ' , final_part.part_name,'(IN -', input_group.process_name, ')'))  as output_part_name, COALESCE(input_group.input_part_id,final_wel.output_part) as input_part_id,  COALESCE(input_group.input_part_name,CONCAT('semi finished part - ' , final_part.part_name,'(from -', input_group.previous_process_name, ')')) as input_part_name, sum(input_group.qty) as qty, input_group.previous_process_id,  input_group.previous_process_name,input_group.process,input_group.process_name,input_group.level,input_group.path FROM input_group  
left join process_wel_tbl final_wel on final_wel.process_id = input_group.final_process_id
left join parts_tbl final_part on final_part.part_id = final_wel.output_part

GROUP BY input_group.process_id,COALESCE(input_group.input_part_id,final_wel.output_part)
order by input_group.final_process_id ),
stock_group as(SELECT if(stock_godown.creditor_id = production_godown.creditor_id,js.qty,0) as same_godown_stock, if(stock_sec.dep_sec_id = production_sec.dep_sec_id,js.qty,0) as same_sec_stock, stock_godown.creditor_name as stock_godown_name, stock_department.dep_name as stock_department_name, stock_sec.sec_name as stock_sec_name, ifnull(js.qty, 0) as stock_qty, production_godown.creditor_name as production_godown_name, production_department.dep_name as production_department_name, production_sec.sec_name as production_sec_name, wtm.cost as production_cost, wtm.min_time as production_min_time, wtm.max_time as production_max_time, process_group.process_id, final_process_id, output_part, output_part_name, input_part_id, input_part_name, process_group.qty, previous_process_id, previous_process_name, process, process_name, level, path
 FROM process_group

left join jaysan_stock js on process_group.input_part_id = js.part_id and ifnull(process_group.previous_process_id, 0) = ifnull(js.process_id, 0)
left join work_time_master wtm on wtm.ori_process_id = process_group.process_id and wtm.is_default = 1
left join creditors stock_godown on stock_godown.creditor_id = js.godown
left join creditors production_godown on production_godown.creditor_id = wtm.godown_id
left join department stock_department on stock_department.dep_id = js.dep
left join department production_department on production_department.dep_id = wtm.dep_id
left join dep_section stock_sec on stock_sec.dep_sec_id = js.sec
left join dep_section production_sec on production_sec.dep_sec_id = wtm.dep_sec_id 
order by process_group.final_process_id, process_group.process_id),

stock_cat as(SELECT sum(stock_qty) as total_stock,sum(stock_qty)- sum(same_godown_stock)-sum(same_sec_stock) as outside_stock, sum(same_godown_stock) - sum(same_sec_stock) as godown_stock, sum(same_sec_stock) as same_sec_stock,JSON_ARRAYAGG(JSON_OBJECT('stock_godown_name', stock_godown_name, 'stock_department_name', stock_department_name, 'stock_sec_name', stock_sec_name, 'stock_qty', stock_qty)) as stock_info, sum(stock_qty) as stock_qty, production_godown_name, production_department_name, production_sec_name, production_cost, production_min_time, production_max_time, process_id, final_process_id, output_part, output_part_name, input_part_id, input_part_name, qty, previous_process_id, previous_process_name, process, process_name, level, path FROM stock_group GROUP BY input_part_id,process_id)

SELECT if(outside_stock < qty,qty-total_stock,0) as production_qty, if(same_sec_stock > qty,0,if(godown_stock>(qty-same_sec_stock),qty-same_sec_stock,if(outside_stock > (qty-same_sec_stock-godown_stock),0,qty-same_sec_stock-godown_stock))) as godown_transfer_qty, outside_stock,godown_stock,same_sec_stock,stock_info,stock_qty,production_godown_name,production_department_name,production_sec_name,production_cost,production_min_time,production_max_time,process_id,final_process_id,output_part,output_part_name,input_part_id,input_part_name,qty,previous_process_id,previous_process_name,process,process_name,level,path FROM stock_cat




-- SELECT final_process_id,output_part,output_part_name,JSON_ARRAYAGG(JSON_OBJECT('input_part_id', input_part_id, 'input_part_name', input_part_name, 'qty', qty,'previous_process_id', previous_process_id, 'previous_process_name', previous_process_name)) AS input_parts,process,process_name,level,path FROM input_group GROUP BY final_process_id ORDER BY level, final_process_id
