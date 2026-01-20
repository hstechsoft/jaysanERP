-- Active: 1766425908618@@srv1002.hstgr.io@3306@u333142350_jaysan
SELECT subgroup.sub_group_name,cgroup.group_name,mtype.type_name,model.model_name,pro.product_name,pro.product_id,model.model_id,mtype.mtid,cgroup.group_id,subgroup.sub_group_id FROM subgroup_type_price sub_price
LEFT JOIN customer_subgroup_master subgroup on sub_price.sub_group_id = subgroup.sub_group_id
LEFT join customer_group_master cgroup on subgroup.group_id = cgroup.group_id
LEFT JOIN jaysan_model_type mtype on mtype.mtid = sub_price.mtid
LEFT join jaysan_product_model model on mtype.pid = model.model_id
LEFT join jaysan_final_product pro on model.product_id = pro.product_id
GROUP BY pro.product_id,model.model_id,mtype.mtid,subgroup.sub_group_id
ORDER BY subgroup.sub_group_name,cgroup.group_name,mtype.type_name,model.model_name,pro.product_name;
