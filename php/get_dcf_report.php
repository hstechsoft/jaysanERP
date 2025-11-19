with ass_info as(SELECT
  
  
    IFNULL(ap.qty, 0) AS qty,
    ap.dated,
    ap.assign_type,

    ap.godown,
   
    sop.opid,
    godown.godown_name,
    IFNULL(
        SUM(qty) OVER(
    PARTITION BY sop.opid
    ),
    0
    ) AS assigned_qty, 
   sop.required_qty,
    sop.required_qty -(SUM(IFNULL(qty, 0)) OVER(PARTITION BY sop.opid)) AS unassigned_qty,
   SUM(ifnull(qty,0)) over (PARTITION by ap.opid order by ap.assign_type) as assigntype_total_count,


 sum(IFNULL(qty, 0)) over ( PARTITION BY ap.opid,ap.assign_type,ap.godown ) as finished_godown_count,
                  sum(IFNULL(qty, 0)) over ( PARTITION BY ap.opid,ap.assign_type,ap.dated ) as production_date_count
 
                 
                 
      

   
FROM
    assign_product ap

LEFT JOIN godown ON ap.godown = godown.gid
RIGHT JOIN sales_order_product sop ON
    ap.opid = sop.opid 
),

assign_product_details as(select opid,assign_type,qty,godown,
dated as production_date,godown_name,assigned_qty,required_qty,unassigned_qty,assigntype_total_count,finished_godown_count,production_date_count from ass_info WHERE 1 
-- AND assign_type in ("Waiting") and unassigned_qty > 1 and godown = 0 and dated BETWEEN '2025-05-10' and '2025-12-10' and  unassigned_qty > 0 

 GROUP by opid,assign_type,production_date,godown),
dcf_info as(SELECT ap.ass_id,ap.opid,ap.qty,ap.dcf_id ,dcf.sts as dcf_sts,
sum(qty) over (PARTITION by opid,dcf_id) as dcf_count,
sum(qty) over (PARTITION by opid) as total_dcf_count
FROM assign_product ap INNER join dcf on ap.dcf_id = dcf.dcf_id ),

dcf_details as (SELECT opid,dcf_id,dcf_sts,dcf_count,total_dcf_count from dcf_info
-- WHERE opid = 687 and dcf_sts = 'HOD'
GROUP by opid,dcf_id order by opid )
,
ap_opid as(SELECT opid,assign_type, assigntype_total_count,JSON_ARRAYAGG(
        JSON_OBJECT('godown_name',godown_name,'production_date' ,production_date , 'finished_godown_count', finished_godown_count, 'production_date_count',production_date_count)) as assign_details,required_qty,assigned_qty,unassigned_qty  from assign_product_details  GROUP by opid,assign_type),
        
assign_final as( SELECT opid,required_qty,assigned_qty,unassigned_qty,JSON_ARRAYAGG(
        JSON_OBJECT('assign_type',assign_type,'assigntype_total_count',assigntype_total_count,'assign_details',assign_details)) as assign_info from ap_opid GROUP by opid)
        ,
dcf_final as (SELECT opid, JSON_ARRAYAGG(
        JSON_OBJECT('dcf_id',dcf_id,'dc_sts',dcf_sts,'dcf_count',dcf_count)) as dcf_details,total_dcf_count from dcf_details GROUP by opid )
        
        
        SELECT * from  sales_order_info_view


        
