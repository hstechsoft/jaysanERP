CREATE OR REPLACE VIEW job_card_view AS
select
    laser_job_card.assign_date,
    laser_job_card.shift,
    lm.jmid,
    lm.run_time,
    lm.handling_time,
    jm.godown_id,
    jm.dep_id,
    jm.dep_sec_id,
    godown.creditor_name as godown,
    dep.dep_name as dep,
    sec.sec_name as sec,
    jm.machine_name,
    laser_job_card.assigned_by,
    laser_job_card.laser_machine_id,
    laser_job_card.qty,
    laser_job_card.remark,
    laser_job_card.operator_id,
    laser_job_card.status,
    laser_job_card.scarp_weight,
    laser_job_card.job_card_id,
    laser_job_card.scarp_qty,
    laser_job_card.nesting_details_id,
    laser_job_card.finished_date,
    emp.emp_name as operator_name
   
from
    laser_job_card
    left join laser_machine lm on laser_job_card.laser_machine_id = lm.laser_machine_id
    left join jaysan_machine jm on lm.jmid = jm.jmid
    left join creditors godown on jm.godown_id = godown.creditor_id
    left join department dep on jm.dep_id = dep.dep_id
    left join dep_section sec on jm.dep_sec_id = sec.dep_sec_id
    left join employee emp on laser_job_card.operator_id = emp.emp_id