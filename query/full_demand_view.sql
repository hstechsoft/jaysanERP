

CREATE OR REPLACE VIEW full_demand_view AS with input_demand as(select ipv.input_part_id,ipv.previous_process_id,sum(ipv.needed) as total_needed from input_part_demand_view ipv WHERE needed > 0 and input_part_id > 0
group by ipv.input_part_id
union all
select ipv.input_part_id,ipv.previous_process_id,sum(ipv.needed) as total_needed from input_part_demand_view ipv WHERE needed > 0 and input_part_id is null GROUP BY ipv.previous_process_id),
stock_group  as (
    select sv.part_id,sv.process_id,sum(sv.reserve_qty) as reserve_qty from stock_view sv where sv.reserve_type = 'job_work_order' and sv.part_id > 0 GROUP BY sv.part_id
    union all
        select sv.part_id,sv.process_id,sum(sv.reserve_qty) as reserve_qty from stock_view sv where sv.reserve_type = 'job_work_order' and sv.part_id is null GROUP BY sv.process_id

)
select input_demand.input_part_id,input_demand.previous_process_id,input_demand.total_needed,ifnull(stock_group.reserve_qty,0) as external_reserve_qty
from input_demand
left join stock_group on
case when input_demand.input_part_id is not null 
then input_demand.input_part_id = stock_group.part_id 
else
    input_demand.previous_process_id = stock_group.process_id
    end


