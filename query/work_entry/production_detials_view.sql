WITH qr_summary as (SELECT qr_work_entry.qr_work_id,qr_work_entry.emp_id, qr_work_entry.start_time, qr_work_entry.end_time,qr_work_entry.free_time,qr_work_entry.production_id,qr_work_entry.reason,qr_work_entry.work_sts,
sum(work_process.qty * work_process.work_time_per_unit) as total_process_time,

TIMESTAMPDIFF(MINUTE,qr_work_entry.start_time,qr_work_entry.end_time) as total_time,
COUNT(work_process.process_id) as total_processes


FROM qr_work_entry

    left join work_process on qr_work_entry.qr_work_id = work_process.current_work_id
 
    WHERE
   qr_work_entry.production_id in (SELECT production_id FROM qr_work_entry INNER join work_process on qr_work_entry.qr_work_id = work_process.current_work_id WHERE qr_work_entry.work_sts = 'finished' GROUP BY process_id) group by qr_work_entry.qr_work_id),
   



production_summary as(SELECT qr_work_id,emp_id,start_time,end_time,free_time,production_id,reason,work_sts,total_process_time,total_time,total_processes ,
sum(total_process_time) over (partition by production_id) as total_process_time_per_production,
(total_time - free_time)/(sum(total_process_time) over (partition by production_id)) * 100 as compeltion_percentage
from qr_summary),


production_summary1 as (SELECT max(qr_work_id) as qr_work_id,production_id, sum(total_processes) as total_proess_count,count(qr_work_id) as total_work_count,sum(total_time) as total_qr_work_time,sum(total_process_time) as process_total_time,sum(free_time) as total_free_time,JSON_ARRAYAGG(JSON_OBJECT('qr_work_id',qr_work_id,'start_time',date_only(start_time),'end_time',date_only(end_time),'compeltion_percentage',compeltion_percentage,'free_time',free_time,'work_sts',work_sts)) as production_entry_data from production_summary GROUP BY production_id)
SELECT production_summary1.*,JSON_ARRAYAGG(JSON_OBJECT('part_id',work_process.part_id,'qty',work_process.qty,'work_time_per_unit',work_process.work_time_per_unit,'total_time',work_process.qty * work_process.work_time_per_unit,'process_id',work_process.process_id,'process_name',jaysan_process.process_name,'part_name',parts_tbl.part_name)) as worked_process_data FROM production_summary1  
inner join work_process on production_summary1.qr_work_id = work_process.current_work_id
  
    left join process_wel_tbl on work_process.process_id = process_wel_tbl.process_id
    left join jaysan_process on process_wel_tbl.process = jaysan_process.process_id
    LEFT join parts_tbl on work_process.part_id = parts_tbl.part_id
   