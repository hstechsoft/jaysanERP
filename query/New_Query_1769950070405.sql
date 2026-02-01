SELECT 
    JSON_ARRAYAGG(
        JSON_OBJECT(
            'payment_id', payment_id,
            'amount', amount,
            'approved_by', approved_by,
            'approved_date', approved_date,
            'dated', dated,
            'oid', oid,
            'payment_date', payment_date,
            'ref_no', ref_no,
            'sts', sts,
            'utr_no', utr_no,
            'formatted_datetime', DATE_FORMAT(dated, '%d-%m-%Y %h:%i %p')
        )
    ) as payments_json,
    (
        SELECT JSON_ARRAYAGG(
            JSON_OBJECT(
                'amount', amount,
                'utr_no', utr_no
            )
        )
        FROM (
            SELECT sao.amount,
                   (SELECT utr_no FROM jaysan_payment WHERE payment_id = (SELECT payment_id FROM sale_payment_advance sa WHERE sa.advance_id = sao.advance_ref_id)) as utr_no 
            FROM sale_payment_advance sao 
            WHERE oid = 704 AND advance_ref_id > 0 
            GROUP BY sao.oid
        ) as subquery
    ) as advances_json
FROM jaysan_payment 
WHERE oid = 702
