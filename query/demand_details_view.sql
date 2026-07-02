-- Active: 1766385460907@@srv1002.hstgr.io@3306@u333142350_jaysan

CREATE OR REPLACE VIEW demand_details_view AS with planner as(select pp.planner_id, count(ppp.planner_part_id) as planned_qty,date_only(pp.dated) as plan_date,employee.emp_name as planner_name,sov.* from production_planner pp
inner join employee on pp.created_by = employee.emp_id
inner JOIN production_planner_parts ppp on pp.planner_id = ppp.planner_id
inner JOIN assign_product ap on  ppp.assign_id = ap.ass_id
inner join sales_order_info_view sov on ap.opid = sov.opid GROUP BY ap.opid,pp.planner_id)
select planner_id, sum(planned_qty) as total_planned_qty, planner_name, plan_date,JSON_ARRAYAGG(json_object('opid', opid, 'cus_name', cus_name,'product', product,'model_name', model_name,'type_name', type_name,'order_no', order_no,'planned_qty', planned_qty)) as sale_order_details from planner GROUP BY planner_id