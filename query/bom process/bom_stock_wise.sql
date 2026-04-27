-- Active: 1766425908618@@srv1002.hstgr.io@3306@u333142350_jaysan
with RECURSIVE input_group as (
    select 
    previous_process_id, 
    qty,
    0 as level from input_wel_parts iwp1 WHERE  iwp1.process_id = 2796 
    
    UNION ALL
SELECT 
    iwp2.previous_process_id, 
    iwp2.qty, 
    ig.level + 1 as level from input_wel_parts iwp2
inner JOIN input_group ig ON iwp2.process_id = ig.previous_process_id 
),

process_available as (
    SELECT previous_process_id as process_available_id, sum(qty) as qty ,level FROM input_group 
    WHERE previous_process_id IS NOT NULL GROUP BY previous_process_id 
    UNION ALL
    SELECT 2796 as process_available_id,1, 0 as level 
)

SELECT * FROM process_available