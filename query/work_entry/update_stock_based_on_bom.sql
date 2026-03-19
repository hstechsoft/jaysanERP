-- Active: 1766385460907@@srv1002.hstgr.io@3306@u333142350_jaysan
SELECT pwt.process,iwp.input_part_id,iwp.previous_process_id,iwp.qty FROM process_wel_tbl pwt 
inner join input_wel_parts iwp on pwt.process_id = iwp.process_id WHERE  pwt.process_id = 304