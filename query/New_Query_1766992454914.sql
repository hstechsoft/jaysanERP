SELECT parts_tbl.part_name,bom_output.part_id as output,bom_input.part_id as input,component_cat, ROW_NUMBER() OVER () as row_num
 from bom_output 
inner join bom_input on bom_output.bom_id = bom_input.bom_id
left join parts_tbl on bom_output.part_id = parts_tbl.part_id
WHERE bom_input.part_id = bom_output.part_id and component_cat <> 'Process'
ORDER BY output;

