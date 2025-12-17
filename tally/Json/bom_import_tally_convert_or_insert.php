<?php
/**
 * BOM IMPORT – CONVERT OR INSERT (NO DUPLICATES)
 */

include __DIR__ . '/../../php/db_head.php';

ini_set('memory_limit', '1024M');
set_time_limit(0);

$jsonFile = 'stock_enriched.json';

/* ---------------------------------------
   LOAD JSON
--------------------------------------- */
$data = json_decode(file_get_contents($jsonFile), true);
if (!$data || empty($data['StockItem'])) die("Invalid JSON");

/* ---------------------------------------
   PART MAP
--------------------------------------- */
$partMap = [];
$q = $conn->query("SELECT part_id, unique_part_id FROM parts_tbl");
while ($r = $q->fetch_assoc()) {
    $partMap[$r['unique_part_id']] = (int)$r['part_id'];
}

/* ---------------------------------------
   PROCESS
--------------------------------------- */
foreach ($data['StockItem'] as $item) {

    if (empty($item['unique_part_id'])) continue;
    if (empty($item['MULTICOMPONENTLIST'])) continue;
    if (!isset($partMap[$item['unique_part_id']])) continue;

    $parentPartId = $partMap[$item['unique_part_id']];

    foreach ($item['MULTICOMPONENTLIST'] as $component) {

        if (empty($component['COMPONENTLISTNAME'])) continue;
        $cat = $conn->real_escape_string($component['COMPONENTLISTNAME']);

        /* ---------------------------------------
           BOM OUTPUT: CONVERT OR INSERT
        --------------------------------------- */
        $conn->query("
            INSERT INTO bom_output (part_id, component_cat, sub_ass, bom_source)
            VALUES ($parentPartId, '$cat', 0, 'TALLY')
            ON DUPLICATE KEY UPDATE
                bom_source = 'TALLY'
        ");

        // get bom_id
        $r = $conn->query("
            SELECT bom_id FROM bom_output
            WHERE part_id = $parentPartId AND component_cat = '$cat'
            LIMIT 1
        ");
        $bomId = (int)$r->fetch_assoc()['bom_id'];

        if (empty($component['MULTICOMPONENTITEMLIST'])) continue;

        /* ---------------------------------------
           INPUT AGGREGATION
        --------------------------------------- */
        $agg = [];

        foreach ($component['MULTICOMPONENTITEMLIST'] as $child) {

            if (empty($child['unique_part_id'])) continue;
            if (!isset($partMap[$child['unique_part_id']])) continue;

            $childPartId = $partMap[$child['unique_part_id']];

            preg_match('/[\d.]+/', $child['ACTUALQTY'] ?? '0', $m);
            $qty = isset($m[0]) ? (float)$m[0] : 0;

            $key = $bomId . '|' . $childPartId;

            if (!isset($agg[$key])) {
                $agg[$key] = [
                    'part_id' => $childPartId,
                    'qty' => $qty,
                    'nature' => $child['NATUREOFITEM'] ?? '',
                    'godown' => $child['GODOWNNAME'] ?? ''
                ];
            } else {
                $agg[$key]['qty'] += $qty;
            }
        }

        /* ---------------------------------------
           BOM INPUT: CONVERT OR INSERT
        --------------------------------------- */
        foreach ($agg as $row) {

            $nature = $conn->real_escape_string($row['nature']);
            $godown = $conn->real_escape_string($row['godown']);

            $conn->query("
                INSERT INTO bom_input
                    (bom_id, part_id, qty, nature_of_item, godown_name, bom_source)
                VALUES
                    ($bomId, {$row['part_id']}, {$row['qty']}, '$nature', '$godown', 'TALLY')
                ON DUPLICATE KEY UPDATE
                    qty = VALUES(qty),
                    nature_of_item = VALUES(nature_of_item),
                    godown_name = VALUES(godown_name),
                    bom_source = 'TALLY'
            ");
        }
    }
}

echo "✅ BOM SYNC DONE – MANUAL CONVERTED, NO DUPLICATES\n";
