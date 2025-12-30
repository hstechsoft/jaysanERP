SELECT bom_input.* from bom_input
 inner JOIN parts_tbl on bom_input.part_id = parts_tbl.part_id WHERE parts_tbl.sub_ass = 1 GROUP BY  bom_input.part_id 

select * FROM bom_output INNER join parts_tbl on bom_output.part_id = parts_tbl.part_id WHERE parts_tbl.sub_ass = 1