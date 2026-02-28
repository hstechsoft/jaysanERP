SELECT
    subtype_group_id,
 
    IFNULL(subgroup_type_price.max_price, 0) AS max_price,
    IFNULL(subgroup_type_price.min_price, 0) AS min_price,
    IFNULL(subgroup_type_price.mrp, 0) AS mrp,
    (
    SELECT
        dep_section.sec_name
    FROM
        dep_section
    WHERE
        dep_section.dep_sec_id = subtype_group_id
) AS sec_name,
JSON_ARRAYAGG(
    JSON_OBJECT(
        'msid',
        jaysan_model_subtype.msid,
        'subtype_name',
        subtype_name,
        'is_default',
        is_default,
        'is_reduce',
        is_reduce,
        'max_price',
        IFNULL(subgroup_type_price.max_price, 0),
        'min_price',
        IFNULL(subgroup_type_price.min_price, 0),
        'mrp',
        IFNULL(subgroup_type_price.mrp, 0),
        'price',
        IFNULL(subgroup_subtype_price.price, 0),
        'discount',
        IFNULL(
            subgroup_subtype_price.discount,
            0
        )
    )
) AS price_details
FROM
    jaysan_model_subtype
LEFT JOIN subgroup_type_price ON jaysan_model_subtype.mtid = subgroup_type_price.mtid 
LEFT JOIN subgroup_subtype_price ON jaysan_model_subtype.msid = subgroup_subtype_price.msid AND subgroup_subtype_price.sub_group_id = $subgroup_id
WHERE
    jaysan_model_subtype.mtid = $mtid
GROUP BY
    subtype_group_id
ORDER BY
    subtype_group_id
DESC;