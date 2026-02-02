CREATE OR REPLACE VIEW sale_order_payment_full AS
WITH advance_given_details AS (
    SELECT 
        JSON_ARRAYAGG(
            JSON_OBJECT(
                'advance_id', advance_id,
                'utr_no', utr_no,
                'received_amount', jaysan_payment.amount,
                'advance_given', sale_payment_advance.amount
            )
        ) AS advance_deposite_details,
        SUM(sale_payment_advance.amount) AS advance_deposite,
        sale_payment_advance.oid
    FROM sale_payment_advance
    LEFT JOIN jaysan_payment 
        ON sale_payment_advance.payment_id = jaysan_payment.payment_id
    WHERE advance_ref_id IS NULL
    GROUP BY sale_payment_advance.oid
),

sop AS (
    SELECT 
        SUM(price) AS total_product_price,
        oid
    FROM sales_order_product
    GROUP BY oid
),

spares AS (
    SELECT 
        SUM(amount) AS total_spares_amount,
        oid 
    FROM sale_order_spares 
    GROUP BY oid
),

advance_taken AS (
    SELECT 
        oid,
        JSON_ARRAYAGG(
            JSON_OBJECT(
                'ref_no', ref_no,
                'payment_date', payment_date,
                'utr_no', utr_no,
                'advance_given', advance_given,
                'advance_taken', advance_taken
            )
        ) AS advance_taken_details,
        SUM(advance_taken) AS total_advance_taken 
    FROM (
        SELECT 
            sa.oid,
            sa.advance_ref_id,
            utr_no,
           ref_no,
            DATE_FORMAT(dated, '%d-%m-%Y %h:%i %p') as payment_date,
            advance.amount AS advance_given,
            SUM(sa.amount) AS advance_taken 
        FROM sale_payment_advance sa
        LEFT JOIN sale_payment_advance AS advance 
            ON sa.advance_ref_id = advance.advance_id
        LEFT JOIN jaysan_payment 
            ON advance.payment_id = jaysan_payment.payment_id
        WHERE sa.payment_id IS NULL 
          AND sa.advance_ref_id > 0
        GROUP BY sa.advance_ref_id, sa.oid
    ) AS advance_ref_details
    GROUP BY oid
),

received_payment AS (
    SELECT 
        SUM(amount) AS total_received_payment,
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
    ) as received_details,
        oid 
    FROM jaysan_payment
    GROUP BY oid
),

payment_summary AS (
    SELECT 
        sof.oid,
        total_received_payment,
        received_details,
        advance_deposite_details,
        advance_deposite,
        advance_taken_details,
        total_advance_taken,
        total_product_price,
        total_spares_amount,
        (IFNULL(advance_deposite,0) 
         + IFNULL(total_product_price,0) 
         + IFNULL(total_spares_amount,0)) AS debit,
        (IFNULL(total_received_payment,0) 
         + IFNULL(total_advance_taken,0)) AS credit
    FROM sales_order_form sof
    LEFT JOIN received_payment 
        ON sof.oid = received_payment.oid
    LEFT JOIN advance_given_details 
        ON sof.oid = advance_given_details.oid
    LEFT JOIN advance_taken 
        ON sof.oid = advance_taken.oid
    LEFT JOIN sop 
        ON sof.oid = sop.oid
    LEFT JOIN spares 
        ON sof.oid = spares.oid
)

SELECT 
    payment_summary.*,
    debit - credit AS bal
FROM payment_summary;
