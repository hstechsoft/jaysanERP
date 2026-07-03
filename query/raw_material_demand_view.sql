

CREATE OR REPLACE VIEW raw_material_demand_view AS
select
    wo.godown,
    wo.dep,
    wo.sec,
    demand.part_id,
    demand.process_id,
    JSON_ARRAYAGG(
        JSON_OBJECT(
            'work_order_id',
            wo.work_order_id,
            'work_order_no',
            wo.work_order_no,
            'pending_qty',
            wo.pending_qty
        )
    ) as work_orders,
    sum(wo.pending_qty) as total_pending_qty,
    iwp.input_part_id,
    iwp.previous_process_id,
    iwp.qty,
    iwp.qty * sum(wo.pending_qty) as total_input_qty,
    sum(ifnull(sv.reserve_qty, 0)) as total_avail
from
    work_order wo
    left join demand on wo.demand_id = demand.demand_id
    left join input_wel_parts iwp on demand.process_id = iwp.process_id
  LEFT JOIN stock_view sv
ON CASE
       WHEN demand.part_id IS NOT NULL
           THEN sv.part_id = demand.part_id and sv.reserve_type = 'work_order'
       ELSE
           sv.process_id = demand.process_id and sv.reserve_type = 'work_order'
   END
GROUP BY
    demand.part_id,
    demand.process_id,
    wo.godown,
    wo.dep,
    wo.sec

select demand.process_id,
iwp.input_part_id,
    iwp.previous_process_id,
    wo.godown,
    wo.dep,
    wo.sec,
    iwp.qty,
    JSON_ARRAYAGG(
        JSON_OBJECT(
            'work_order_id',
            wo.work_order_id,
            'work_order_no',
            wo.work_order_no,
            'pending_qty',
            wo.pending_qty
        )
    ) as work_orders from demand 
     
inner join input_wel_parts iwp on iwp.process_id = demand.process_id
left join work_order wo on wo.demand_id = demand.demand_id
GROUP BY
    input_part_id,
  previous_process_id,
    wo.godown,
    wo.dep,
    wo.sec

 select demand.part_id, demand.process_id, demand.demand_id, wo.godown, wo.dep, wo.sec, wo.pending_qty
from demand
    inner join work_order wo on wo.demand_id = demand.demand_id




 CREATE OR REPLACE VIEW raw_material_demand_view AS with work_details as (select demand.part_id, demand.process_id, JSON_ARRAYAGG(
        JSON_OBJECT(
            'work_order_id',
            wo.work_order_id,
            'work_order_no',
            wo.work_order_no,
            'pending_qty',
            wo.pending_qty
        )
    ) as work_orders, wo.godown, wo.dep, wo.sec, sum(wo.pending_qty) as total_pending_qty
from demand
    inner join work_order wo on wo.demand_id = demand.demand_id
GROUP BY
    demand.part_id,
    demand.process_id,
    wo.godown,
    wo.dep,
    wo.sec)
select wd.process_id, wd.work_orders, wd.godown, wd.dep, wd.sec, wd.total_pending_qty, iwp.input_part_id, iwp.previous_process_id, iwp.qty, iwp.qty * wd.total_pending_qty as total_input_qty,sv.reserve_qty as total_avail
from work_details wd
inner join input_wel_parts iwp on wd.process_id = iwp.process_id
left join stock_view sv on CASE
       WHEN iwp.input_part_id IS NOT NULL
           THEN sv.part_id = iwp.input_part_id and sv.reserve_type = 'work_order' and sv.godown <=> wd.godown and sv.dep <=> wd.dep and sv.sec <=> wd.sec
       ELSE
           sv.process_id = wd.process_id and sv.reserve_type = 'work_order' and sv.godown <=> wd.godown and sv.dep <=> wd.dep and sv.sec <=> wd.sec
   END



