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

WHERE   wd.work_id = (select work_id from work_done_table where emp_id = 141 and end_date is NULL order by work_id desc limit 1) GROUP BY qr.work_sts


SELECT if(
        qr_work_id > 0, qr.end_time, (
            SELECT if(
                    qr_work_id > 0, qr.end_time, (
                        SELECT start_date
                        FROM work_done_table
                        WHERE
                            work_id = 1860
                    )
                )
            from qr_work_entry qr
            where
                qr.work_done_id = 1860
                and qr.work_sts = 'finished'
                and qr.production_id is null
            ORDER BY qr.qr_work_id DESC
            limit 1
        )
    ) as in_process_exists
from qr_work_entry qr
where
    qr.work_done_id = 1860
    and qr.production_id is null
ORDER BY qr.qr_work_id DESC
limit 1

SELECT COALESCE(
    (SELECT qr.end_time
     FROM qr_work_entry qr
     WHERE qr.work_done_id = 1860
     AND qr.work_sts = 'finished'
     AND qr.production_id IS NULL
     AND qr.qr_work_id > 0
     LIMIT 1),
    (SELECT start_date from work_done_table WHERE work_id = 1860)
) AS in_process_exists;
          


