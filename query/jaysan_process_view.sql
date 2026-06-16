
       CREATE OR REPLACE VIEW jaysan_process_view AS  with process_input as( SELECT      if(
                        iwp.previous_process_id is null,
                        pt_in.part_name,
                        concat(
                            ifnull(
                                pt_in.part_name,
                               CONCAT('semi finished part of ',pt_final.part_name)
                            ),
                            ' (',
                            jp_in.process_name,
                            ')'
                        )
                    ) as part ,
                    iwp.input_part_id,
                    iwp.previous_process_id,
                    iwp.qty,
                    pwt.process_id,
                    jp.process_name,
                    pwt.output_part,
                  if(pwt.output_part is null,CONCAT('semi finished part of ',pt_process_final.part_name),pt_process_final.part_name)  as final_part,
                  pt_process_final.part_name as final_part_only,
                  pt_process_final.part_id as final_part_id
                  
              
                    
                              from process_wel_tbl pwt
            inner join input_wel_parts iwp on pwt.process_id = iwp.process_id

            left join parts_tbl pt_in on iwp.input_part_id = pt_in.part_id
            left join process_wel_tbl pwt_in on iwp.previous_process_id = pwt_in.process_id
            left join process_wel_tbl pwt_final on pwt_in.final_process_id = pwt_final.process_id
            left join parts_tbl pt_final on pwt_final.output_part = pt_final.part_id
            left join jaysan_process jp_in on pwt_in.process = jp_in.process_id


            left join jaysan_process jp on pwt.process = jp.process_id
            
            left join process_wel_tbl pwt_process_final on pwt_process_final.process_id = pwt.final_process_id
            left join parts_tbl pt_process_final on pt_process_final.part_id = pwt_process_final.output_part),
            process_group as(SELECT  JSON_ARRAYAGG(JSON_OBJECT('part',part,'input_part',input_part_id,'qty',qty,'previous_process_id',previous_process_id)) as input_parts, process_id,process_name,final_part,final_part_only,final_part_id,output_part from process_input group by process_id)

                SELECT input_parts,
               pg.process_id,process_name,
               if(wtm.godown_id is null,NULL, JSON_ARRAYAGG(JSON_OBJECT('godown_id',wtm.godown_id,'dep_id',wtm.dep_id,'sec_id',wtm.dep_sec_id,'godown_name' ,creditors.creditor_name,'department',department.dep_name,'section',dep_section.sec_name,'cost',cost,'max_time',max_time,'min_time',min_time,'wtid',wtid))) as godown_details,
               final_part,final_part_only,final_part_id,output_part 
from process_group pg
                left join work_time_master wtm on pg.process_id = wtm.ori_process_id
                left join creditors on wtm.godown_id = creditors.creditor_id
    left join department on wtm.dep_id = department.dep_id
    left join dep_section on wtm.dep_sec_id = dep_section.dep_sec_id group by pg.process_id