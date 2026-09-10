CREATE OR REPLACE VIEW nesting_details_view AS
 with
    nes_details as (
        select
         
            nes_work.nesting_details_id,
            nes_work.nesting_id,
            emp.emp_name as created_by_name,
            nes_work.created_by,
            nes_work.material_qty
        from
            nesting_details nes_work
            left join employee emp on nes_work.created_by = emp.emp_id
         
        group by
            nes_work.nesting_details_id,
            nes_work.nesting_id
    ),

     nes_master as (
     select
     mas.nes_master_id as nesting_id,
      mas.nesting_name,
    mas.material_id,
    mas.path,
    mas.nesting_type,
    mas.std_length,
    mat_part.part_name as material_name,
    scarp_part.part_name as scrap_name,
    mas.created_by as master_created_by,
    emp.emp_name as master_created_name,
    JSON_ARRAYAGG(
        JSON_OBJECT(
            'nes_part_id',
            nesting_parts.nes_part_id,
            'part_id',
            nesting_parts.part_id,
            'qty',
            nesting_parts.qty,
            'part_name',
            nest_part.part_name
        )
    ) as nesting_parts_details
    from nesting_master mas   
   left join  nesting_parts on nesting_parts.nesting_id = mas.nes_master_id
   left join parts_tbl nest_part on nesting_parts.part_id = nest_part.part_id
   left join parts_tbl mat_part on mas.material_id = mat_part.part_id
   left join parts_tbl scarp_part on mas.scrap_part_id = scarp_part.part_id
   left join employee emp on mas.created_by = emp.emp_id
  
    group by mas.nes_master_id
 )
 select nm.nesting_id,
 nm.nesting_name,
 nm.material_id,
 nm.path,
 nm.nesting_type,
 nm.std_length,
 nm.material_name,
 nm.scrap_name,
 nm.master_created_by,
 nm.master_created_name,
 nm.nesting_parts_details,
 nd.nesting_details_id,
 nd.created_by_name,
 nd.created_by,
 nd.material_qty
 from nes_master nm  LEFT join nes_details nd on nm.nesting_id = nd.nesting_id