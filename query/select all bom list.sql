-- Active: 1766425908618@@srv1002.hstgr.io@3306@u333142350_jaysan
-- Get all BOM list with multiple BOMs and at least one default BOM,,,
SELECT bom_output.part_id,parts_tbl.part_name,sum(ifnull(is_default,0)),GROUP_CONCAT(bom_output.bom_id,component_cat),COUNT(bom_output.part_id),JSON_ARRAYAGG(JSON_OBJECT('bom_id',bom_id,'component_cat',component_cat,'is_default',is_default)) FROM `bom_output`
inner join parts_tbl on bom_output.part_id = parts_tbl.part_id
WHERE component_cat <> 'process' GROUP by bom_output.part_id having COUNT(bom_output.bom_id) > 1 and sum(ifnull(is_default,0)) = 0
ORDER BY `bom_output`.`component_cat` ASC 

-- finished query
SELECT bom_output.part_id,parts_tbl.part_name,sum(ifnull(is_default,0)),GROUP_CONCAT(bom_output.bom_id,component_cat),COUNT(bom_output.part_id),JSON_ARRAYAGG(JSON_OBJECT('bom_id',bom_id,'component_cat',component_cat,'is_default',is_default)) FROM `bom_output`
inner join parts_tbl on bom_output.part_id = parts_tbl.part_id
WHERE component_cat <> 'process' GROUP by bom_output.part_id having COUNT(bom_output.bom_id) > 1 and sum(ifnull(is_default,0)) > 0
ORDER BY `bom_output`.`component_cat` ASC


 