CREATE OR REPLACE VIEW production_plan_view AS
select
    pp.created_by,
    date_only (pp.dated) as production_plan_date,
    pp.planner_id,
    pp.remark,
    pp_employee.emp_name as pp_created_by_name,
    soiv.*,
    count(ppp.assign_id) as production_request_count
from
    production_planner pp
    inner join production_planner_parts ppp on pp.planner_id = ppp.planner_id
    inner JOIN employee pp_employee on pp.created_by = pp_employee.emp_id
    inner join assign_product ap on ppp.assign_id = ap.ass_id
    inner join sales_order_info_view soiv on ap.opid = soiv.opid
    group by pp.planner_id, soiv.oid