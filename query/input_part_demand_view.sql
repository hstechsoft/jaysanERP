


CREATE OR REPLACE VIEW input_part_demand_view AS
WITH
-- get work order process details
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
        -- get input for demand process
        SELECT
            iwp.process_id as work_process_id,
            iwp.input_part_id,
            -- if input part_id is not null previous process_id change to null
            CASE
                WHEN iwp.input_part_id IS NOT NULL THEN NULL
                ELSE iwp.previous_process_id
            END AS previous_process_id,
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
    internal_reserved as (
        select work_process_id,
        godown,
        dep,
        sec,
        part_id ,
          CASE
                WHEN part_id IS NOT NULL THEN NULL
                ELSE process_id
            END AS process_id,
            qty from input_demand WHERE cat = "work_order" 
    ),
        stock_transfer as (
        select work_process_id,
        godown,
        dep,
        sec,
        part_id ,
          CASE
                WHEN part_id IS NOT NULL THEN NULL
                ELSE process_id
            END AS process_id,
            qty from input_demand WHERE cat = "stock_transfer" 
    ),
       dc as (
        select work_process_id,
        godown,
        dep,
        sec,
        part_id ,
          CASE
                WHEN part_id IS NOT NULL THEN NULL
                ELSE process_id
            END AS process_id,
            qty from input_demand WHERE cat = "dc" 
    ),
        transport as (
        select work_process_id,
        godown,
        dep,
        sec,
        part_id ,
          CASE
                WHEN part_id IS NOT NULL THEN NULL
                ELSE process_id
            END AS process_id,
            qty from input_demand WHERE cat = "transport" 
    )

    select iq.work_process_id,
        iq.work_orders,
         iq.pending_qty as pending_process_qty,
           iq.input_part_id,
           iq.previous_process_id,
             iq.required_qty,
         
          
           iq.godown,
           iq.dep,
           iq.sec,
         
        
           ir.qty as total_reserve_qty,
           st.qty as stock_allocation_qty,
           dc.qty as dc_qty,
           tr.qty as transport_qty,
           iq.required_qty - (ifnull(ir.qty,0) + ifnull(st.qty,0) + ifnull(dc.qty,0) + ifnull(tr.qty,0)) as needed

    from input_qty iq 
    left join internal_reserved ir on iq.work_process_id = ir.work_process_id and iq.input_part_id <=> ir.part_id and iq.previous_process_id <=> ir.process_id and iq.godown <=> ir.godown and iq.dep <=> ir.dep and iq.sec <=> ir.sec

    left join stock_transfer st on iq.work_process_id = st.work_process_id and iq.input_part_id <=> st.part_id and iq.previous_process_id <=> st.process_id and iq.godown <=> st.godown and iq.dep <=> st.dep and iq.sec <=> st.sec

    left join dc  on iq.work_process_id = dc.work_process_id and iq.input_part_id <=> dc.part_id and iq.previous_process_id <=> dc.process_id and iq.godown <=> dc.godown and iq.dep <=> dc.dep and iq.sec <=> dc.sec

left JOIN transport tr on iq.work_process_id = tr.work_process_id and iq.input_part_id <=> tr.part_id and iq.previous_process_id <=> tr.process_id and iq.godown <=> tr.godown and iq.dep <=> tr.dep and iq.sec <=> tr.sec