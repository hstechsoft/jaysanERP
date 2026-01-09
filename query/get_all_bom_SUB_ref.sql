DROP TEMPORARY TABLE IF EXISTS tmp_bom_hi;
DROP TEMPORARY TABLE IF EXISTS child_part;
DROP TEMPORARY TABLE IF EXISTS parent_part;

    CREATE TEMPORARY TABLE tmp_bom_hi AS
    WITH RECURSIVE bom_hi AS (

        /* ========= Anchor ========= */
        SELECT
            bo.part_id AS output_part,
            bi.part_id AS input_part,
            bi.qty,
            pt_hi.sub_ass,
            0 AS level,
            bo.component_cat
        FROM bom_output bo
        JOIN bom_input bi ON bo.bom_id = bi.bom_id
        JOIN parts_tbl pt_hi ON bi.part_id = pt_hi.part_id
        WHERE bo.part_id = (
            SELECT part_id
            FROM parts_tbl
            WHERE part_name = '001 Roller Assmbly 312'
        )
        AND bo.component_cat = 'Roller Assy 12.5.25'

        UNION ALL

        /* ========= Recursive ========= */
        SELECT
            boc.part_id AS output_part,
            bi.part_id AS input_part,
            bi.qty,
            pt.sub_ass,
            h.level + 1,
            boc.component_cat
        FROM bom_output boc
        JOIN bom_hi h
            ON boc.part_id = h.input_part
        AND h.sub_ass = 1
        JOIN bom_input bi ON boc.bom_id = bi.bom_id
        JOIN parts_tbl pt ON bi.part_id = pt.part_id
        WHERE boc.component_cat <> 'Process'
        AND boc.part_id <> h.output_part
    )

    SELECT * FROM bom_hi;



    CREATE TEMPORARY TABLE child_part (
    
        input_part      INT,
        qty             INT
    
    );
      CREATE TEMPORARY TABLE parent_part (
    
        input_part      INT,
        qty             INT
    
    );

INSERT INTO child_part (input_part, qty)
SELECT input_part, qty
FROM tmp_bom_hi WHERE tmp_bom_hi.LEVEL>0;

INSERT INTO parent_part (input_part, qty)
SELECT input_part, qty
FROM tmp_bom_hi WHERE tmp_bom_hi.LEVEL=0;


SELECT * FROM parent_part LEFT join child_part on parent_part.input_part = child_part.input_part
UNION
SELECT * FROM parent_part RIGHT join child_part on parent_part.input_part = child_part.input_part