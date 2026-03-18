-- Active: 1766425908618@@srv1002.hstgr.io@3306@u333142350_jaysan
with  sec_wise as (SELECT pwt.previous_process_id, pwt.process,pwt.process_id,pwt.process_title,wtm.dep_id,wtm.dep_sec_id,wtm.godown_id,wtm.wtid FROM work_time_master wtm inner JOIN process_wel_tbl pwt on wtm.ori_process_id = pwt.process_id WHERE  wtm.godown_id = 359 and wtm.dep_id = 36 and wtm.dep_sec_id = 45 and wtm.machine_id = 54), 
outpart as (SELECT 	get_output_part(process_id) as outpart,  previous_process_id, process,process_id,process_title,dep_id,dep_sec_id,godown_id,wtid FROM sec_wise )
SELECT outpart.*,jp.process_name,pt.part_name as output_part FROM outpart
 inner join jaysan_process jp on outpart.process = jp.process_id
 inner join parts_tbl pt on outpart.outpart = pt.part_id



