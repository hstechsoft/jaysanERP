CREATE OR REPLACE VIEW stock_view AS
SELECT
    js.stock_id,
    js.godown,
    js.dep,
    js.sec,
    js.batch_id,
    js.qty,
    js.dated,
    js.finished_godown,
    js.part_id,
    js.remark,
    js.emp_id,
    js.process_id,
    js.stock_unique_key,
    sr.reserve_type,
    sr.stock_reserve_id,
    sr.reserve_qty
FROM jaysan_stock AS js
INNER JOIN stock_reserve AS sr
    ON js.stock_id = sr.stock_id;