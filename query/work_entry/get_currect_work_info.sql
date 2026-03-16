-- Active: 1766385460907@@srv1002.hstgr.io@3306@u333142350_jaysan
SELECT JSON_ARRAYAGG(JSON_OBJECT(
        'start_time', qr.start_time,
        'end_time', qr.end_time,
        'production_id', qr.production_id,
        'work_sts', qr.work_sts,
        'work_id', wd.work_id
    )) as work_entries,qr.work_sts
FROM work_done_table wd 

left join qr_work_entry qr on wd.work_id = qr.work_done_id

WHERE   wd.work_id = 1860 GROUP BY qr.work_sts

