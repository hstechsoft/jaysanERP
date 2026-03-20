-- Active: 1766425908618@@srv1002.hstgr.io@3306@u333142350_jaysan
SELECT ifnull(SUM(js.qty), 0) as total_stock_qty,  ifnull(SUM(js.qty), 0) - (iwp.qty * 3)  as remaining_qty, js.godown,js.dep,js.sec, pwt.process_id,iwp.input_part_id,iwp.previous_process_id,iwp.qty,jp.process_name as inprocess FROM process_wel_tbl pwt 
inner join input_wel_parts iwp on iwp.process_id = pwt.process_id
inner join jaysan_process jp on jp.process_id = pwt.process
left join jaysan_stock js on pwt.process_id = js.process_id and iwp.input_part_id = js.part_id and js.godown = 1166 and js.dep = 29 and js.sec = 34  
 WHERE pwt.process_id = 2707  GROUP BY iwp.input_part_id     