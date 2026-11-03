with work_order_custom as (
  select 

    wo.demand_id,
      wo.created_by,
      wo.qty,
      wo.pending_qty,
      wo.work_order_id,
      ifnull (wo.completed_qty, 0) as wo_completed_qty,
      wo.due_date,
     
      wo.godown,
      wo.dep,
      wo.sec,
   
      date_only ((wo.due_date)) as wo_due_date
     
     
from work_order wo
inner join demand on wo.demand_id = demand.demand_id
where 1
-- and demand.process_id = 0
-- and wo.due_date < current_date()
-- and wo.pending_qty > 0
-- and wo.godown = 359

),
 place_wise_report as(
select 

      demand.demand_id,
      demand.process_id,
      demand.plan_id,
      demand.demand_qty,
      JSON_ARRAYAGG(
        JSON_OBJECT(
      
          'wo_created_by', wo.created_by,
          'wo_qty', ifnull (wo.qty, 0),
          'wo_pending_qty', ifnull (wo.pending_qty, 0),
          'wo_work_order_id', wo.work_order_id,
          
          'wo_completed_qty', ifnull (wo.wo_completed_qty, 0),
          'wo_due_date', wo.wo_due_date,
          
          'wo_created_by_name', wo_emp.emp_name
        )
      ) as work_order_details,
    

    
     
    
      wo.godown,
      wo.dep,
      wo.sec,
   
      wo_godown.creditor_name as wo_godown_name,
      wo_dep.dep_name as wo_dep_name,
      wo_dep_sec.sec_name as wo_dep_sec_name
     
from  work_order_custom wo
inner join demand on demand.demand_id = wo.demand_id
   left join creditors wo_godown on wo.godown = wo_godown.creditor_id
      left join department wo_dep on wo.dep = wo_dep.dep_id
      left join dep_section wo_dep_sec on wo.sec = wo_dep_sec.dep_sec_id
      left join employee wo_emp on wo.created_by = wo_emp.emp_id
group by wo.godown, wo.dep, wo.sec,demand.plan_id,demand.process_id),
  planner_product as (
    SELECT 
      ppv.created_by as pp_created_by,
      ppv.production_plan_date,
      ppv.planner_id,
    
      ppv.pp_created_by_name,
      
      ppv.type_id,
      ppv.model_id,
      ppv.sub_type,
     
      ppv.model_name,
      ppv.product_id,
      ppv.product,
      ppv.type_name,
      ppv.production_request_count,

      JSON_ARRAYAGG(JSON_OBJECT
      (
        'oid', ppv.oid,
        'order_category', ppv.order_category,
       
        'dated', ppv.dated,
    
        'first_payment_date', ppv.first_payment_date,
        'customer_id', ppv.customer_id,
        'cus_name', ppv.cus_name,
        'cus_phone', ppv.cus_phone,
        'opid', ppv.opid,
        'type_id', ppv.type_id,
        'model_id', ppv.model_id,
        'sub_type', ppv.sub_type,
        'required_qty', ppv.required_qty,
      
        'model_name', ppv.model_name,
        'product_id', ppv.product_id,
        'product', ppv.product,
        'type_name', ppv.type_name
      
      
      )) as order_details
       from production_plan_view ppv 
       where 1
        -- and ppv.customer_id  = 1184
        -- and ppv.product_id = 1
        -- and ppv.model_id = 1
        -- and ppv.type_id = 1
       group by ppv.planner_id
       
  ),
plan_summary as(select 
 plan_id,
   godown,
    dep,
    sec,
      wo_godown_name,
      wo_dep_name,
      wo_dep_sec_name,
JSON_ARRAYAGG(
        JSON_OBJECT(
          'demand_id', place_wise_report.demand_id,
          'process_id', place_wise_report.process_id,
          'process_name', jpv.process_name,
          'final_part', jpv.final_part,
          'output_part', jpv.output_part,
          'work_order_details', work_order_details
        )
      ) as process_details
 from place_wise_report
 inner join jaysan_process_view jpv on jpv.process_id = place_wise_report.process_id
 group by godown, dep, sec, plan_id)
 
 select 
 JSON_ARRAYAGG(
  JSON_OBJECT(
    'plan_id', plan_summary.plan_id,
    'plan_created_by', pp.pp_created_by,
    'plan_date', pp.production_plan_date,
    'pp_created_by_name', pp.pp_created_by_name,
  'order_details', pp.order_details,
    'process_details', plan_summary.process_details
  )
 ) as plan_details,
 plan_id,
 
   godown,
    dep,
    sec,
      wo_godown_name,
      wo_dep_name,
      wo_dep_sec_name,
      process_details
 from plan_summary 
 inner join planner_product pp on pp.planner_id = plan_summary.plan_id
 GROUP BY godown, dep, sec;

  