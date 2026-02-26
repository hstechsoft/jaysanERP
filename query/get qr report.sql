with qr_report as(SELECT date_time_only(qr_work_entry.start_time) as start_time, qr_work_entry.production_id, qr_work_entry.qr_work_id, machine_production_taken.ass_id  
FROM qr_work_entry  
INNER JOIN machine_production_taken ON qr_work_entry.production_id = machine_production_taken.production_id GROUP BY qr_work_entry.production_id),
ass_details as (
    SELECT qr_report.*,assign_product.opid,assign_product.assign_type,date_only(assign_product.dated) as production_date,assign_product.emergency_order FROM assign_product inner join qr_report on assign_product.ass_id = qr_report.ass_id
)
SELECT * FROM ass_details  inner join sales_order_info_view on ass_details.opid = sales_order_info_view.opid