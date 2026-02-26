-- Active: 1766425908618@@srv1002.hstgr.io@3306@u333142350_jaysan
with qr_report as( SELECT JSON_ARRAYAGG (JSON_OBJECT(
  'start_time', date_time_only(qr_work_entry.start_time),
  'production_id', qr_work_entry.production_id,
  'qr_work_id', qr_work_entry.qr_work_id,
  'ass_id', CONVERT(machine_production_taken.ass_id USING utf8mb4) COLLATE utf8mb4_unicode_ci,
  'emp_name', CONVERT(employee.emp_name USING utf8mb4) COLLATE utf8mb4_unicode_ci
)) as qr_details,ass_id,emp_name

FROM qr_work_entry  
INNER JOIN machine_production_taken ON qr_work_entry.production_id = machine_production_taken.production_id 
inner JOIN employee on qr_work_entry.emp_id = employee.emp_id
WHERE qr_work_entry.production_id = 2 GROUP BY machine_production_taken.production_id),
ass_details as (
    SELECT qr_report.*,assign_product.opid,assign_product.assign_type,date_only(assign_product.dated) as production_date,assign_product.emergency_order FROM assign_product inner join qr_report on assign_product.ass_id = qr_report.ass_id
)
SELECT * FROM ass_details  inner join sales_order_info_view on ass_details.opid = sales_order_info_view.opid


