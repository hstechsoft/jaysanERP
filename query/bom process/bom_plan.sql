with RECURSIVE
    bom_plan as (
        SELECT
            iwp_parent.input_part_id,
            iwp_parent.previous_process_id,
            iwp_parent.process_id,
            iwp_parent.qty,
            js.qty as stock_qty,
            0 as level
        FROM
            input_wel_parts iwp_parent
            -- inner  join process_wel_tbl pwt_parent on pwt_parent.process_id = iwp_parent.process_id
            -- inner join process_wel_tbl pwt_fianl on pwt_parent.final_process_id = pwt_fianl.process_id
            left join jaysan_stock js on js.process_id = iwp_parent.previous_process_id
        WHERE
            iwp_parent.process_id = 2796
            and IFNULL((
                SELECT SUM(js1.qty)
                FROM jaysan_stock js1
                WHERE js1.process_id = iwp_parent.process_id
            ), 0) <= 1
            -- qty to produced

            UNION ALL

        SELECT
            iwp_child.input_part_id,
            iwp_child.previous_process_id,
            iwp_child.process_id,
            iwp_child.qty,
            js.qty as stock_qty,
            level + 1
        FROM
            input_wel_parts iwp_child
           
            left join jaysan_stock js on js.process_id = iwp_child.previous_process_id
             inner join bom_plan bp ON bp.previous_process_id = iwp_child.process_id and IFNULL(bp.stock_qty, 0) < IFNULL(bp.qty * 2, 0)
                 -- qty to produced
    )
    SELECT * FROM bom_plan
    



   