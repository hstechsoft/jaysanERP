<?php
/**
 * PART IMPORT + AUTO GST FIX
 */

include __DIR__ . '/../../php/db_head.php';
include __DIR__ . '/fix_gstrate_lib.php';

ini_set('memory_limit', '1024M');
set_time_limit(0);

$enrichedJson = 'stock_enriched.json';

/* ---------------------------------------
   STEP 1: IMPORT / UPDATE PARTS
--------------------------------------- */

$json = file_get_contents($enrichedJson);
if (!$json) die("❌ Cannot read enriched JSON");

$data = json_decode($json, true);
if (!$data || empty($data['StockItem'])) die("❌ Invalid JSON");

$inserted = 0;
$updated  = 0;

foreach ($data['StockItem'] as $item) {

    if (empty($item['unique_part_id']) || empty($item['Name'])) continue;

    $uid   = $conn->real_escape_string($item['unique_part_id']);
    $name  = $conn->real_escape_string($item['Name']);
    $parent= $conn->real_escape_string($item['Parent'] ?? '');
    $cat   = $conn->real_escape_string($item['CATEGORY'] ?? '');
    $base  = $conn->real_escape_string($item['BASEUNITS'] ?? '');

    // UPSERT
    $sql = "
        INSERT INTO parts_tbl (unique_part_id, part_name, Parent, category, baseunits, tally_part)
        VALUES ('$uid', '$name', '$parent', '$cat', '$base', 1)
        ON DUPLICATE KEY UPDATE
            part_name = VALUES(part_name),
            Parent    = VALUES(Parent),
            category  = VALUES(category),
            baseunits = VALUES(baseunits),
            tally_part = 1
    ";

    if ($conn->query($sql)) {
        if ($conn->affected_rows === 1) $inserted++;
        else $updated++;
    }
}

echo "✅ PART IMPORT DONE | Inserted: $inserted | Updated: $updated\n";

/* ---------------------------------------
   STEP 2: AUTO GST FIX (NO MANUAL RUN)
--------------------------------------- */

$gstUpdated = fix_gstrate_from_enriched_json($conn, $enrichedJson);

echo "✅ GST AUTO FIX COMPLETED | Rows updated: $gstUpdated\n";
