-- Active: 1766425908618@@srv1002.hstgr.io@3306@u333142350_jaysan
with iv_deatils as(select iv.work_process_id,iv.work_orders,iv.pending_process_qty,iv.input_part_id, 
if(iv.input_part_id is null,concat('semi finished part (',pt_final.part_name,')'),pt.part_name) as input_part_name,
iv.previous_process_id,iv.required_qty,iv.godown,iv.dep,iv.sec,iv.total_reserve_qty,iv.needed,iv.dc_qty,iv.transport_qty,jpv.final_part,jpv.input_parts,jpv.process_name from input_part_demand_view iv 
 inner join jaysan_process_view jpv on iv.work_process_id = jpv.process_id
 left join parts_tbl pt on iv.input_part_id <=> pt.part_id
 left join process_wel_tbl pwt on iv.previous_process_id <=> pwt.process_id
 left join process_wel_tbl pwt_final on pwt.final_process_id <=> pwt_final.process_id
 left join parts_tbl pt_final on pwt_final.output_part <=> pt_final.part_id),
 job_work_reserved as (
    select sv.part_id, sv.process_id, sum(sv.reserve_qty) as total_reserve_qty, JSON_ARRAYAGG(JSON_OBJECT(
        'same_godown', if(sv.godown = '1087',true,false),
        'godown', sv.godown,
        'dep', sv.dep,
        'sec', sv.sec,
        'reserve_qty', sv.reserve_qty,
        'stock_reserve_id', sv.stock_reserve_id,
        'stock_id', sv.stock_id
    )) as stock_reserve_details from stock_view sv WHERE sv.reserve_type ="job_work_order" and sv.part_id is null
    group by sv.process_id

    union all

    select sv.part_id, sv.process_id, sum(sv.reserve_qty) as total_reserve_qty, JSON_ARRAYAGG(JSON_OBJECT(
        'same_godown', if(sv.godown = '1087',true,false),
        'godown', sv.godown,
        'dep', sv.dep,
        'sec', sv.sec,
        'reserve_qty', sv.reserve_qty,
        'stock_reserve_id', sv.stock_reserve_id,
        'stock_id', sv.stock_id
    )) as stock_reserve_details from stock_view sv WHERE sv.reserve_type ="job_work_order" and sv.part_id is not null
    group by sv.part_id
 )
 select iv.work_process_id,iv.work_orders,iv.pending_process_qty,iv.input_part_id,iv.input_part_name,
 iv.previous_process_id,iv.required_qty,iv.godown,iv.dep,iv.sec,iv.total_reserve_qty,iv.needed,iv.dc_qty,iv.transport_qty,iv.final_part,iv.input_parts,iv.process_name,jwr.total_reserve_qty as job_work_qty,jwr.stock_reserve_details from iv_deatils iv  
 left join job_work_reserved jwr on iv.input_part_id <=> jwr.part_id and iv.previous_process_id <=> jwr.process_id

