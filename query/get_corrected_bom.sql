-- Active: 1766425908618@@srv1002.hstgr.io@3306@u333142350_jaysan
   WITH RECURSIVE bom_hi AS (

        /* ========= Anchor ========= */
        SELECT
            bo.part_id AS output_part,
            part_out.part_name AS output_part_name,
            bi.bom_in_id as bom_in_id,
            bi.part_id AS input_part,
            bi.qty,
            bi.sub_ass_qty,
            pt_hi.sub_ass,
            0 AS level,
            bo.component_cat,
         CAST((SELECT part_name FROM parts_tbl WHERE part_id = bo.part_id) AS CHAR) AS path
        FROM bom_output bo
        JOIN bom_input bi ON bo.bom_id = bi.bom_id
        inner join parts_tbl part_out on bo.part_id = part_out.part_id
        JOIN parts_tbl pt_hi ON bi.part_id = pt_hi.part_id
        WHERE bo.bom_id  = (SELECT bo_get.bom_id from bom_output bo_get WHERE bo_get.part_id = '7202' and bo_get.component_cat = 'de' and bo_get.component_cat <> 'Process' )
        UNION ALL

        /* ========= Recursive ========= */
        SELECT
            boc.part_id AS output_part,
            part_out.part_name AS output_part_name,
            bi.bom_in_id as bom_in_id,  
            bi.part_id AS input_part,
            bi.qty*h.qty AS qty,
            pt.sub_ass,
            bi.sub_ass_qty,
            h.level + 1,
            boc.component_cat,
        CAST(CONCAT(h.path, '>', (SELECT part_name FROM parts_tbl WHERE part_id = boc.part_id)) AS VARCHAR(500))


        FROM bom_output boc
        JOIN bom_hi h
            ON boc.part_id = h.input_part
        AND h.sub_ass = 1
        JOIN bom_input bi ON boc.bom_id = bi.bom_id
        inner join parts_tbl part_out on boc.part_id = part_out.part_id
        JOIN parts_tbl pt ON bi.part_id = pt.part_id
        WHERE boc.component_cat <> 'Process'
        AND boc.part_id <> h.output_part
   )
   SELECT JSON_ARRAYAGG(JSON_OBJECT(
       'output_part', output_part,
       'bom_in_id', bom_in_id,
       'input_part', input_part,
       'qty', qty,
       'sub_ass_qty', sub_ass_qty,
       'sub_ass', sub_ass,
       'level', level,
       'component_cat', component_cat,
       'path', path,
       'corrected_qty', qty - sub_ass_qty
   )) AS bom_data,
   output_part,
   output_part_name,
   level
   FROM bom_hi
   GROUP BY level, output_part;