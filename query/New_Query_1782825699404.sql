-- Active: 1766385460907@@srv1002.hstgr.io@3306@u333142350_jaysan
with
    demand as (
        select
           iwp.process_id,
           sum(work_order.qty) as work_order_qty,
            sum(iwp.qty) as input_qty,
           sum(work_order.qty * iwp.qty) as total_production_qty,
            iwp.previous_process_id,
            iwp.input_part_id,
            work_order.godown,
            work_order.dep,
            work_order.sec
        from
            input_wel_parts iwp
            inner join demand on iwp.process_id = demand.process_id
            inner join work_order on demand.demand_id = work_order.demand_id
        WHERE
            iwp.previous_process_id <=> 2768 group by godown,dep,sec
    ),
    self_demand as (
        select *
        from demand
        where
            godown <=> 1166
            and dep <=> NULL
            and sec <=> NULL
    ) ,
    reserved_stock as (
              select   
        sr.stock_reserve_id,
        js.part_id,
        js.process_id,
        js.godown,
        js.dep,
        js.sec,
        js.stock_id,
        sr.reserve_qty,
        sr.reserve_type,
        js.qty as stock_qty
        from jaysan_stock js 
         LEFT join stock_reserve sr on sr.stock_id = js.stock_id and reserve_type = 'work_order' 
          where    js.godown <=> 1166 and js.dep <=> NULL and js.sec <=> NULL
    )



select
    self_demand.process_id,
    self_demand.work_order_qty,
    self_demand.input_qty,
    self_demand.total_production_qty,
    self_demand.previous_process_id,
    self_demand.input_part_id,
    self_demand.godown,
    self_demand.dep,
    self_demand.sec,
    js.stock_id,
    js.stock_qty,
    js.stock_reserve_id,
    js.reserve_qty,
    js.reserve_type,
  self_demand.total_production_qty-ifnull(js.reserve_qty,0) as remaining_reserve_qty

from
    self_demand
    left join reserved_stock js on self_demand.input_part_id <=> js.part_id
    and self_demand.previous_process_id <=> js.process_id and  self_demand.godown <=> js.godown and self_demand.dep <=> js.dep and self_demand.sec <=> js.sec