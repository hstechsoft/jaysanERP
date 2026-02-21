-- Active: 1766385460907@@srv1002.hstgr.io@3306@u333142350_jaysan
SELECT bom_output.bom_id FROM `bom_output`
inner join bom_input on bom_output.bom_id = bom_input.bom_id
INNER join parts_tbl outpart on bom_output.part_id = outpart.part_id
inner join  parts_tbl inpart on bom_input.part_id = inpart.part_id

WHERE outpart.sub_ass = 0 and inpart.sub_ass = 1 group by bom_output.bom_id


SELECT * FROM bom_output inner join parts_tbl on bom_output.part_id = parts_tbl.part_id WHERE parts_tbl.sub_ass = 1 GROUP BY parts_tbl.part_id having COUNT(parts_tbl.part_id)>1
