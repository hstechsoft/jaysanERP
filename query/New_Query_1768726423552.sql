-- Active: 1766425908618@@srv1002.hstgr.io@3306@u333142350_jaysan


SELECT   jaysan_model_subtype.msid,subtype_name,is_default,is_reduce,subtype_group_id,(select dep_section.sec_name from dep_section WHERE dep_section.dep_sec_id = subtype_group_id)as section_name,ifnull(group_type_price.max_price,0) as max_price,ifnull(group_type_price.min_price,0) as min_price,ifnull(group_type_price.mrp,0) as mrp,ifnull(subgroup_subtype_price.price,0) as price,ifnull(subgroup_subtype_price.discount,0) as discount FROM jaysan_model_subtype
left join group_type_price on jaysan_model_subtype.mtid=group_type_price.mtid and group_type_price.group_id = (select group_id from customer_subgroup_master where sub_group_id=1)
left join subgroup_subtype_price on jaysan_model_subtype.msid=subgroup_subtype_price.msid and subgroup_subtype_price.sub_group_id=1
 WHERE jaysan_model_subtype.mtid =33