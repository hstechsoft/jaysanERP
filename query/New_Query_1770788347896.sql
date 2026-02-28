SELECT emp_id,date_time_only(qr_work_entry.start_time) as start_time, qr_work_entry.production_id, qr_work_entry.qr_work_id, machine_production_taken.ass_id  
FROM qr_work_entry  
INNER JOIN machine_production_taken ON qr_work_entry.production_id = machine_production_taken.production_id 