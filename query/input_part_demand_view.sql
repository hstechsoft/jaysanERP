


CREATE OR REPLACE VIEW input_part_demand_view AS with work_order_qty as (
    select demand.process_id, wo.godown,wo.dep,wo.sec,sum(wo.pending_qty) as pending_qty from work_order wo
    inner join demand on wo.demand_id = demand.demand_id  GROUP BY demand.process_id, wo.godown,wo.dep,wo.sec
),
input_qty as(
    select iwp.process_id,iwp.input_part_id,iwp.previous_process_id,iwp.qty,woq.pending_qty,woq.godown,woq.dep,woq.sec,iwp.qty*woq.pending_qty as required_qty from input_wel_parts iwp 
    inner join work_order_qty woq on iwp.process_id = woq.process_id
),

input_reserve as(
    select input_part_id,previous_process_id,required_qty, input_qty.godown, input_qty.dep, input_qty.sec,sv.reserve_qty from input_qty
    left join stock_view sv on case when input_part_id is not null then sv.part_id = input_qty.input_part_id and sv.godown <=> input_qty.godown  and sv.dep <=> input_qty.dep  and sv.sec <=> input_qty.sec and sv.reserve_type = 'work_order' else sv.process_id = input_qty.previous_process_id and sv.godown <=> input_qty.godown  and sv.dep <=> input_qty.dep  and sv.sec <=> input_qty.sec and sv.reserve_type = 'work_order' end
)
SELECT input_part_id,previous_process_id,required_qty, godown, dep, sec, sum(ifnull(reserve_qty,0)) as total_reserve_qty,required_qty - sum(ifnull(reserve_qty,0)) as needed from input_reserve group by input_part_id,previous_process_id,required_qty, godown, dep, sec, reserve_qty


