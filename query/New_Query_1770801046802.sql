-- Active: 1766385460907@@srv1002.hstgr.io@3306@u333142350_jaysan
SELECT * FROM mrf_details_view WHERE mrf_batch_qty > mrf_receive_qty

SELECT * FROM mrf_details_view WHERE mrf_batch_qty <= mrf_receive_qty

SELECT * FROM mrf_details_view WHERE mrf_batch_qty > mrf_po_qty