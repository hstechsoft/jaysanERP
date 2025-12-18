<?php
/**
 * FAST BOM IMPORT WITH DUPLICATE PREVENTION
 * (bom_id + part_id aggregation)
 */

include __DIR__ . '/../../php/db_head.php';

ini_set('memory_limit', '1024M');
set_time_limit(0);

$jsonFile = 'stock_enriched.json';

/* ---------------------------------------
   LOAD JSON
--------------------------------------- */
$json = file_get_contents($jsonFile);
if (!$json) die("❌ Cannot read enriched JSON");

$data = json_decode($json, true);
if (!$data || empty($data['StockItem'])) die("❌ Invalid JSON");

/* ---------------------------------------
   PART LOOKUP (unique_part_id → part_id)
--------------------------------------- */
$partMap = [];
$res = $conn->query("SELECT part_id, unique_part_id FROM parts_tbl");
while ($row = $res->fetch_assoc()) {
    $partMap[$row['unique_part_id']] = (int)$row['part_id'];
}

/* ---------------------------------------
   CLEAN BOM (FAST & SAFE)
--------------------------------------- */
$conn->query("SET FOREIGN_KEY_CHECKS=0");
$conn->query("TRUNCATE TABLE bom_input");
$conn->query("TRUNCATE TABLE bom_output");

/* ---------------------------------------
   BUILD BOM OUTPUT DATA
--------------------------------------- */
$bulkOut = [];

foreach ($data['StockItem'] as $item) {

    if (empty($item['unique_part_id']) || empty($item['MULTICOMPONENTLIST'])) continue;
    if (!isset($partMap[$item['unique_part_id']])) continue;

    $outputPartId = $partMap[$item['unique_part_id']];

    foreach ($item['MULTICOMPONENTLIST'] as $comp) {

        if (empty($comp['COMPONENTLISTNAME'])) continue;

        $bulkOut[] = [
            'part_id' => $outputPartId,
            'cat'     => $conn->real_escape_string($comp['COMPONENTLISTNAME']),
            'inputs'  => $comp['MULTICOMPONENTITEMLIST'] ?? []
        ];
    }
}

/* ---------------------------------------
   INSERT BOM OUTPUT (BULK)
--------------------------------------- */
$outMap = []; // index → bom_id
$chunk = 100;

for ($i = 0; $i < count($bulkOut); $i += $chunk) {

    $slice = array_slice($bulkOut, $i, $chunk);
    $values = [];

    foreach ($slice as $row) {
        $values[] = "({$row['part_id']}, '{$row['cat']}', 0)";
    }

    $sql = "
        INSERT INTO bom_output (part_id, component_cat, sub_ass)
        VALUES " . implode(',', $values);

    if (!$conn->query($sql)) {
        die("BOM OUTPUT ERROR: " . $conn->error);
    }

    $firstId = $conn->insert_id;

    for ($j = 0; $j < count($slice); $j++) {
        $outMap[$i + $j] = $firstId + $j;
    }
}

/* ---------------------------------------
   BUILD BOM INPUT (AGGREGATED)
--------------------------------------- */
$inputAgg = []; // key = bom_id|part_id

foreach ($bulkOut as $idx => $row) {

    if (empty($row['inputs'])) continue;
    if (!isset($outMap[$idx])) continue;

    $bomId = $outMap[$idx];

    foreach ($row['inputs'] as $child) {

        if (empty($child['unique_part_id'])) continue;
        if (!isset($partMap[$child['unique_part_id']])) continue;

        $inputPartId = $partMap[$child['unique_part_id']];

        // qty from "1 Nos"
        preg_match('/[\d.]+/', $child['ACTUALQTY'] ?? '0', $m);
        $qty = isset($m[0]) ? (float)$m[0] : 0;

        $nature = $child['NATUREOFITEM'] ?? '';
        $godown = $child['GODOWNNAME'] ?? '';

        $key = $bomId . '|' . $inputPartId;

        if (!isset($inputAgg[$key])) {
            $inputAgg[$key] = [
                'part_id' => $inputPartId,
                'bom_id'  => $bomId,
                'qty'     => $qty,
                'nature'  => $nature,
                'godown'  => $godown
            ];
        } else {
            // 🔥 SUM QTY (DUPLICATE PREVENTION)
            $inputAgg[$key]['qty'] += $qty;
        }
    }
}

/* ---------------------------------------
   INSERT BOM INPUT (BULK)
--------------------------------------- */
$bulkIn = [];

foreach ($inputAgg as $row) {

    $bulkIn[] = "(
        {$row['part_id']},
        {$row['qty']},
        {$row['bom_id']},
        '{$conn->real_escape_string($row['nature'])}',
        '{$conn->real_escape_string($row['godown'])}'
    )";
}

for ($i = 0; $i < count($bulkIn); $i += $chunk) {

    $slice = array_slice($bulkIn, $i, $chunk);

    $sql = "
        INSERT INTO bom_input
            (part_id, qty, bom_id, nature_of_item, godown_name)
        VALUES " . implode(',', $slice);

    if (!$conn->query($sql)) {
        die("BOM INPUT ERROR: " . $conn->error);
    }
}

$conn->query("SET FOREIGN_KEY_CHECKS=1");

/* ---------------------------------------
   DONE
--------------------------------------- */
echo "✅ FAST BOM IMPORT COMPLETED (NO DUPLICATES)\n";
echo "➡ BOM OUTPUT : " . count($bulkOut) . "\n";
echo "➡ BOM INPUT  : " . count($bulkIn) . "\n";
