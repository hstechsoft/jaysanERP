  SELECT if(sum(sop.required_qty) > ifnull(sum(assign_product.qty), 0), 3 ,1) as approve_sts from sales_order_product sop
  LEFT join assign_product on sop.opid = assign_product.opid
  WHERE oid  = (SELECT oid FROM sales_order_product WHERE sales_order_product.opid = 1072) GROUP BY oid