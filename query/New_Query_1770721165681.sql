SELECT if((SELECT 1 FROM bom_correction WHERE outpart_bom_id = 10 and part_id = 1316) IS NOT NULL, '10', (SELECT COUNT(bom_id) from bom_output bo WHERE bo.part_id = 1316 and bo.component_cat <> "Process"));


SELECT if((SELECT 1 FROM bom_correction WHERE outpart_bom_id = 10 and part_id = 1316) IS NOT NULL, ((SELECT bomlist_id FROM bom_correction WHERE outpart_bom_id = 10 and part_id = 1316)), (SELECT bom_id from bom_output bo WHERE bo.part_id = 1316 and bo.component_cat <> "Process" limit 1) );

SELECT * FROM bom_input left join bom_correction on bom_input.part_id = bom_correction.part_id and bom_correction.outpart_bom_id = 10 where bom_input.bom_id = 10;