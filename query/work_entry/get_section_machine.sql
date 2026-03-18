-- Active: 1766425908618@@srv1002.hstgr.io@3306@u333142350_jaysan
SELECT wtm.machine_id, jm.machine_name FROM work_time_master wtm 
inner join jaysan_machine jm on wtm.machine_id = jm.jmid
WHERE wtm.godown_id = 359 and wtm.dep_id = 36 and wtm.dep_sec_id = 45 GROUP BY wtm.machine_id;

