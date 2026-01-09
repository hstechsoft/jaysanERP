CREATE TEMPORARY TABLE parent_bom (
    id INT AUTO_INCREMENT PRIMARY KEY,
    part_id INT,
    qty DECIMAL(10,3)
);

CREATE TEMPORARY TABLE child_bom (
    id INT AUTO_INCREMENT PRIMARY KEY,
    part_id INT,
    qty DECIMAL(10,3)
);
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
        WHERE part_name = '001 Roller Ass 310'
    )
    AND bo.component_cat = 'Roller Assy 10.5.2025'

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

INSERT INTO parent_bom (part_id, qty)
SELECT input_part, qty
FROM bom_hi;
