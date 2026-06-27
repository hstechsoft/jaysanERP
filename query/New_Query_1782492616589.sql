-- Active: 1766385460907@@srv1002.hstgr.io@3306@u333142350_jaysan
with RECURSIVE input_group as (
    select 
    previous_process_id, 
    qty ,
    cast(process_id as char(255)) as process_id
    from input_wel_parts iwp1 
    WHERE  iwp1.process_id = $process_id 
    
    UNION ALL
SELECT 
    iwp2.previous_process_id, 
    iwp2.qty * ig.qty,
  concat(ig.process_id,',',iwp2.process_id) as process_id
    from input_wel_parts iwp2
inner JOIN input_group ig ON iwp2.process_id = ig.previous_process_id 
)
select * from input_group