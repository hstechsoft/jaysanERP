-- Active: 1766385460907@@srv1002.hstgr.io@3306@u333142350_jaysan
DELIMITER $$

CREATE TRIGGER assign_product_after_insert
AFTER INSERT ON assign_product
FOR EACH ROW
BEGIN
    IF NEW.assign_type = 'Production' THEN

        INSERT INTO machine_production (ass_id, dated, line_no)
        VALUES (
            NEW.ass_id,
            NEW.dated,
            (
                SELECT IFNULL(MAX(line_no), 0) + 1
                FROM machine_production
                WHERE dated = NEW.dated
            )
        );

    END IF;
END$$

DELIMITER;

DELIMITER $$
DROP TRIGGER IF EXISTS
    assign_product_after_update $$
CREATE TRIGGER assign_product_after_update AFTER UPDATE
ON
    assign_product FOR EACH ROW
BEGIN
    INSERT INTO assign_product_log(
        ass_id,
        opid,
        qty,
        dated,
        emergency_order,
        assign_type,
        finished_details,
        line_no,
        godown,
        chasis_no,
        dcf_id,
        old_ass_id,
        old_opid,
        old_qty,
        old_dated,
        old_emergency_order,
        old_assign_type,
        old_finished_details,
        old_line_no,
        old_godown,
        old_chasis_no,
        old_dcf_id,
        action_type,
        action_timestamp
    )
VALUES(
    NEW.ass_id,
    NEW.opid,
    NEW.qty,
    NEW.dated,
    NEW.emergency_order,
    NEW.assign_type,
    NEW.finished_details,
    NEW.line_no,
    NEW.godown,
    NEW.chasis_no,
    NEW.dcf_id,
    OLD.ass_id,
    OLD.opid,
    OLD.qty,
    OLD.dated,
    OLD.emergency_order,
    OLD.assign_type,
    OLD.finished_details,
    OLD.line_no,
    OLD.godown,
    OLD.chasis_no,
    OLD.dcf_id,
    'UPDATE',
    NOW()) ; 
    
    IF NEW.assign_type = 'Production' AND NEW.dcf_id = 0 AND NEW.finished_details = 'no_sts' THEN
INSERT INTO machine_production(ass_id, dated, line_no)
VALUES(
    NEW.ass_id,
    NEW.dated,
    (
    SELECT
        IFNULL(MAX(line_no),
        0) + 1
    FROM
        machine_production
    WHERE
        dated = NEW.dated
)
)
ON DUPLICATE KEY
UPDATE
    dated = NEW.dated,
line_no =(
    SELECT
        IFNULL(MAX(line_no),
        0) + 1
    FROM
        machine_production
    WHERE
        dated = NEW.dated
) ;
END IF ;


 IF(
    OLD.assign_type = 'Production' AND NEW.assign_type <> 'Production'
) OR(
    OLD.finished_details = 'no_sts' AND NEW.finished_details <> 'no_sts' AND NEW.assign_type = 'Production'
) THEN
DELETE
FROM
    machine_production
WHERE
    ass_id = OLD.ass_id ;
END IF ; END $$
DELIMITER;



CREATE TRIGGER `ml_insert` AFTER INSERT ON `machine_production`
 FOR EACH ROW INSERT INTO machine_line (ass_id, line_no) VALUES ( NEW.ass_id, NEW.production_id)


CREATE TRIGGER `ml_update` AFTER UPDATE ON `machine_production`
 FOR EACH ROW UPDATE machine_line SET machine_line.ass_id = NEW.ass_id WHERE machine_line.line_no = NEW.production_id