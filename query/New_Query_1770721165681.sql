-- to get all main bom that having child as sub ass

WITH RECURSIVE parent_chain AS (
 
    -- 🔹 Start from the edited BOM
    SELECT 
        bo.bom_id,
        bo.part_id,
        pt.sub_ass
    FROM bom_output bo
    JOIN parts_tbl pt ON pt.part_id = bo.part_id
    WHERE bo.bom_id = 791

    UNION ALL

    -- 🔹 Move upward through parents
    SELECT 
        bo_parent.bom_id,
        bo_parent.part_id,
        pt_parent.sub_ass
    FROM parent_chain pc
    JOIN bom_input bi 
        ON bi.part_id = pc.part_id
    JOIN bom_output bo_parent 
        ON bo_parent.bom_id = bi.bom_id
    JOIN parts_tbl pt_parent 
        ON pt_parent.part_id = bo_parent.part_id

    -- 🛑 stop climbing once MAIN BOM is reached
    WHERE pc.sub_ass = 1
)
SELECT DISTINCT bom_id
FROM parent_chain
WHERE sub_ass = 0;


Received - BOM ID: 66951, Input Part: 7642, Input Qty: 1<br>BOM input updated successfully.<br>
Input part is sub-assembly.<br>
BOM sub-assembly quantity 0 updated successfully.
Part: BR 6003 Sprocket 9T (ID: 1166)Excess Qty: 1
Part: BR 6009  H Nipple (ID: 1172)Excess Qty: 2
Part: BR 6027 POPPET (ID: 1195)Excess Qty: 1
Part: BR 6035 Presure  Control Spring (ID: 1203)Excess Qty: 1
Part: BR 6036 Presure Control Needle (ID: 1204)Excess Qty: 1
Part: BR 6050 OIL BOLT (ID: 1219)Excess Qty: 1
Part: BR 6051 OIL AIR FLOW BOLT (ID: 1220)Excess Qty: 1
Part: BR 6068 3MM KEY (ID: 1237)Excess Qty: 1
Part: BR 6073 Dowty Waser 1/4 (ID: 1242)Excess Qty: 1
Part: BR 6074 Pump Bolt (ID: 1243)Excess Qty: 1
Part: BR 6078 Hy.Manual Spring (ID: 1247)Excess Qty: 1
Part: BR 6079 Hy.Manual Guider (ID: 1248)Excess Qty: 1
Part: BR 6080 Hy.Manual Op.Bar (ID: 1249)Excess Qty: 1
Part: BR 6081 Hy.Manual Op.Suport Bar (ID: 1250)Excess Qty: 1
Part: BR 6082 Hy.Manual Guider Pin (ID: 1251)Excess Qty: 1
Part: BR 6086 Bump Oil Seal Kit (ID: 1256)Excess Qty: 1
Part: BR 6099 Plate Waser M14 (ID: 1275)Excess Qty: 1
Part: BRP 1322 M8x80MM HALF (ID: 2101)Excess Qty: 4
Part: JSS 1120 M5 X 12MM CSK (ID: 4133)Excess Qty: 1
Part: JSS 1140 M5 X 35MM A (ID: 4153)Excess Qty: 1
Part: JSS 1142 M5 X 45MM A (ID: 4155)Excess Qty: 4
Part: JSS 1152 M5 Sunlock Nut (ID: 4165)Excess Qty: 1
Part: JSS 1239 M6 X 12MM A (ID: 4205)Excess Qty: 4
Part: JSS 1385 M8 Spring Waser (ID: 4329)Excess Qty: 4
Part: JSS 1386  Plate Washer M8x21x3mm (ID: 4330)Excess Qty: 5
Part: JSS 3322 M8X8MM Gripscrew (ID: 5580)Excess Qty: 1
Part: JSS 3331 M10X10MM Gripscrew (ID: 5589)Excess Qty: 2
Part: JSS 3341 M12X20MM Gripscrew (ID: 5599)Excess Qty: 1
Part: PUMP FITTING SUB ASSY (ID: 7632)Excess Qty: 1
Part: OIL TANK FITTING SUB ASSY (ID: 7633)Excess Qty: 1
Part: MINIPOL FITTING SUB ASSY (ID: 7634)Excess Qty: 1
Part: DC VALVE FITTING SUB ASSY (ID: 7636)Excess Qty: 1
Part: HY. MANUAL SUB ASSY (ID: 7637)Excess Qty: 1
Part:  H NIPPLE SUB ASSY (ID: 7638)Excess Qty: 1
Part: POPPET SUB ASSY (ID: 7639)Excess Qty: 1
Part: SPROCKET SUB ASSY (ID: 7640)Excess Qty: 1

