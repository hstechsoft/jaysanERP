-- CREATE OR REPLACE VIEW input_part_demand_view AS
-- with
--     work_order_qty as (
--         select demand.process_id, wo.godown, wo.dep, wo.sec, sum(wo.pending_qty) as pending_qty
--         from work_order wo
--             inner join demand on wo.demand_id = demand.demand_id
--         GROUP BY
--             demand.process_id,
--             wo.godown,
--             wo.dep,
--             wo.sec
--     ),
--     input_qty as (
--         select
--             iwp.process_id,
--             iwp.input_part_id,
--             iwp.previous_process_id,
--             iwp.qty,
--             woq.pending_qty,
--             woq.godown,
--             woq.dep,
--             woq.sec,
--             iwp.qty * woq.pending_qty as required_qty
--         from
--             input_wel_parts iwp
--             inner join work_order_qty woq on iwp.process_id = woq.process_id
--     ),
--     input_reserve as (
--         select
--             input_part_id,
--             previous_process_id,
--             required_qty,
--             input_qty.godown,
--             input_qty.dep,
--             input_qty.sec,
--             sv.reserve_qty
--         from
--             input_qty
--             left join stock_view sv on case
--                 when input_part_id is not null then sv.part_id = input_qty.input_part_id
--                 and sv.godown <=> input_qty.godown
--                 and sv.dep <=> input_qty.dep
--                 and sv.sec <=> input_qty.sec
--                 and sv.reserve_type = 'work_order'
--                 else sv.process_id = input_qty.previous_process_id
--                 and sv.godown <=> input_qty.godown
--                 and sv.dep <=> input_qty.dep
--                 and sv.sec <=> input_qty.sec
--                 and sv.reserve_type = 'work_order'
--             end
--     )
-- SELECT
--     input_part_id,
--     previous_process_id,
--     required_qty,
--     godown,
--     dep,
--     sec,
--     sum(ifnull(reserve_qty, 0)) as total_reserve_qty,
--     required_qty - sum(ifnull(reserve_qty, 0)) as needed
-- from input_reserve
-- group by
--     input_part_id,
--     previous_process_id,
--     required_qty,
--     godown,
--     dep,
--     sec,
--     reserve_qty


CREATE OR REPLACE VIEW input_part_demand_view AS
WITH
    work_order_qty AS (
        SELECT
            d.process_id,
            wo.godown,
            wo.dep,
            wo.sec,
            SUM(wo.pending_qty) AS pending_qty,
            JSON_ARRAYAGG(
                JSON_OBJECT(
                    'work_order_id',
                    wo.work_order_id,
                    'work_order_no',
                    wo.work_order_no,
                    'pending_qty',
                    wo.pending_qty,
                    'qty',
                    wo.qty,
                    'dated',
                    wo.created_date,
                    'days',
                    time_diff (
                        wo.created_date,
                        CURRENT_TIMESTAMP(),
                        'day'
                    )
                )
            ) AS work_orders
        FROM work_order wo
            JOIN demand d ON wo.demand_id = d.demand_id
        GROUP BY
            d.process_id,
            wo.godown,
            wo.dep,
            wo.sec
        HAVING
            SUM(wo.pending_qty) > 0
    ),
    input_qty AS (
        SELECT
            iwp.process_id ,
            iwp.input_part_id,
            iwp.previous_process_id,
            iwp.qty,
            woq.pending_qty,
            woq.godown,
            woq.dep,
            woq.sec,
            iwp.qty * woq.pending_qty AS required_qty,
            woq.work_orders
        FROM
            input_wel_parts iwp
            JOIN work_order_qty woq ON iwp.process_id = woq.process_id
    ),

    input_reserve as (
        
           SELECT
        iq.process_id AS work_process_id,
        iq.work_orders,
        iq.pending_qty,
        iq.input_part_id,
        iq.previous_process_id,
        iq.required_qty,
        iq.godown,
        iq.dep,
        iq.sec,
        sum(sv.reserve_qty) as reserve_qty
    FROM input_qty iq
            left join stock_view sv on case
                when iq.input_part_id is not null then sv.part_id = iq.input_part_id
                and sv.godown <=> iq.godown
                -- and sv.dep <=> iq.dep
                -- and sv.sec <=> iq.sec
                and sv.reserve_type = 'work_order'
                else sv.process_id = iq.previous_process_id
                and sv.godown <=> iq.godown
                -- and sv.dep <=> iq.dep
                -- and sv.sec <=> iq.sec
                and sv.reserve_type = 'work_order'
            end

            GROUP BY
                iq.process_id,
              
                iq.input_part_id,
              
               
                iq.godown,
                iq.dep,
                iq.sec
              
            
    ),

input_demand as(SELECT
    ir.work_process_id,
    ir.work_orders,
    ir.pending_qty AS pending_process_qty,
    ir.input_part_id,
    ir.previous_process_id,
    ir.required_qty,
    ir.godown,
    ir.dep,
    ir.sec,
    SUM(IFNULL(ir.reserve_qty, 0)) AS total_reserve_qty,
    ir.required_qty - SUM(IFNULL(ir.reserve_qty, 0)) AS needed
FROM input_reserve ir

GROUP BY
    ir.input_part_id,
    ir.previous_process_id,
    ir.required_qty,
    ir.godown,
    ir.dep,
    ir.sec,
    ir.reserve_qty),
            transport as (
               select tp.part_id,tp.process_id,sum(tp.qty) as qty,tdc.des_godown from transport_parts tp
 inner join transport_dc tdc on tp.transport_dc_id = tdc.transport_dc_id where tdc.sts = 'transport' GROUP BY tp.part_id,tp.process_id,tdc.des_godown
 
    ),
        dc as (
               select tp.part_id,tp.process_id,sum(tp.qty) as qty,tdc.des_godown from transport_parts tp
 inner join transport_dc tdc on tp.transport_dc_id = tdc.transport_dc_id where tdc.sts = 'create' GROUP BY tp.part_id,tp.process_id,tdc.des_godown
 
    )
    SELECT work_process_id,
    work_orders,
  pending_process_qty,
    input_part_id,
    previous_process_id,
    required_qty,
    godown,
    dep,
    sec,
     total_reserve_qty,
   needed,
   dc.qty  as dc_qty,
   transport.qty as transport_qty
   from input_demand
 left join dc on input_demand.input_part_id <=> dc.part_id and input_demand.work_process_id <=> dc.process_id and input_demand.godown <=> dc.des_godown
 left join transport on input_demand.input_part_id <=> transport.part_id and input_demand.work_process_id <=> transport.process_id and input_demand.godown <=> transport.des_godown

--  CREATE OR REPLACE VIEW input_part_demand_view AS
-- WITH
--     work_order_qty AS (
--         SELECT
--             d.process_id,
--             wo.godown,
--             wo.dep,
--             wo.sec,
--             SUM(wo.pending_qty) AS pending_qty,
--             JSON_ARRAYAGG(
--                 JSON_OBJECT(
--                     'work_order_id',
--                     wo.work_order_id,
--                     'work_order_no',
--                     wo.work_order_no,
--                     'pending_qty',
--                     wo.pending_qty,
--                     'qty',
--                     wo.qty,
--                     'dated',
--                     wo.created_date,
--                     'days',
--                     time_diff (
--                         wo.created_date,
--                         CURRENT_TIMESTAMP(),
--                         'day'
--                     )
--                 )
--             ) AS work_orders
--         FROM work_order wo
--             JOIN demand d ON wo.demand_id = d.demand_id
--         GROUP BY
--             d.process_id,
--             wo.godown,
--             wo.dep,
--             wo.sec
--         HAVING
--             SUM(wo.pending_qty) > 0
--     ),
--     input_qty AS (
--         SELECT
--             iwp.process_id ,
--             iwp.input_part_id,
--             iwp.previous_process_id,
--             iwp.qty,
--             woq.pending_qty,
--             woq.godown,
--             woq.dep,
--             woq.sec,
--             iwp.qty * woq.pending_qty AS required_qty,
--             woq.work_orders
--         FROM
--             input_wel_parts iwp
--             JOIN work_order_qty woq ON iwp.process_id = woq.process_id
--     ),
--     input_reserve as (
        
--            SELECT
--         iq.process_id AS work_process_id,
--         iq.work_orders,
--         iq.pending_qty,
--         iq.input_part_id,
--         iq.previous_process_id,
--         iq.required_qty,
--         iq.godown,
--         iq.dep,
--         iq.sec,
--         sv.reserve_qty
--     FROM input_qty iq
--             left join stock_view sv on case
--                 when iq.input_part_id is not null then sv.part_id = iq.input_part_id
--                 and sv.godown <=> iq.godown
--                 and sv.dep <=> iq.dep
--                 and sv.sec <=> iq.sec
--                 and sv.reserve_type = 'work_order'
--                 else sv.process_id = iq.previous_process_id
--                 and sv.godown <=> iq.godown
--                 and sv.dep <=> iq.dep
--                 and sv.sec <=> iq.sec
--                 and sv.reserve_type = 'work_order'
--             end
            
--     )
-- SELECT
--     ir.work_process_id,
--     ir.work_orders,
--     ir.pending_qty AS pending_process_qty,
--     ir.input_part_id,
--     ir.previous_process_id,
--     ir.required_qty,
--     ir.godown,
--     ir.dep,
--     ir.sec,
--     SUM(IFNULL(ir.reserve_qty, 0)) AS total_reserve_qty,
--     ir.required_qty - SUM(IFNULL(ir.reserve_qty, 0)) AS needed
-- FROM input_reserve ir
-- GROUP BY
--     ir.input_part_id,
--     ir.previous_process_id,
--     ir.required_qty,
--     ir.godown,
--     ir.dep,
--     ir.sec,
--     ir.reserve_qty