SELECT 
    st.msid,
    st.is_default,
    st.is_reduce,
    st.subtype_name,
    sp.discount,
    sp.price,
    stp.mrp,
    stp.min_price,
    stp.max_price
FROM jaysan_model_subtype st
LEFT JOIN subgroup_subtype_price sp ON st.msid = sp.msid AND sp.sub_group_id = 23
LEFT JOIN subgroup_type_price stp ON st.mtid = stp.mtid AND stp.sub_group_id = 23
WHERE st.mtid = 32;


