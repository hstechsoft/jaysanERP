<?php
/**
 * SHARED HOSTING SAFE
 * Enrich Tally JSON with unique_part_id
 * Batch DB operations (no MySQL timeout)
 */

include __DIR__ . '/../../php/db_head.php';

ini_set('memory_limit', '1024M');
set_time_limit(0);

$inputFile  = 'JAStkItem.json';
$outputFile = 'stock_enriched.json';

/* --------------------------------------------------
   Find StockItem array (Tally structure safe)
-------------------------------------------------- */
function &find_stock_items(array &$data) {
    if (isset($data['StockItem'])) {
        return $data['StockItem'];
    }
    if (isset($data['ENVELOPE']['BODY']['DATA']['StockItem'])) {
        return $data['ENVELOPE']['BODY']['DATA']['StockItem'];
    }
    $null = [];
    return $null;
}

/* --------------------------------------------------
   LOAD PARTS TABLE INTO MEMORY (ONCE)
-------------------------------------------------- */
$partsCache = [];
$maxPartNo  = 0;

$res = $conn->query("
    SELECT part_name, unique_part_id, tally_part
    FROM parts_tbl
");

if (!$res) {
    die("SQL ERROR (LOAD CACHE): " . $conn->error);
}

while ($row = $res->fetch_assoc()) {

    $partsCache[$row['part_name']] = [
        'unique_part_id' => $row['unique_part_id'],
        'tally_part'     => (int)$row['tally_part']
    ];

    if (!empty($row['unique_part_id'])) {
        $num = (int)substr($row['unique_part_id'], 1);
        if ($num > $maxPartNo) {
            $maxPartNo = $num;
        }
    }
}

/* --------------------------------------------------
   MEMORY-ONLY UNIQUE ID HANDLER
-------------------------------------------------- */
function get_or_create_unique_part_id_cached(
    string $part_name,
    array  &$partsCache,
    int    &$maxPartNo,
    array  &$newParts,
    array  &$tallyUpdates
): ?string {

    $part_name = trim($part_name);
    if ($part_name === '') return null;

    // Already exists
    if (isset($partsCache[$part_name])) {

        if ($partsCache[$part_name]['tally_part'] === 0) {
            $tallyUpdates[$part_name] = 1;
            $partsCache[$part_name]['tally_part'] = 1;
        }

        return $partsCache[$part_name]['unique_part_id'];
    }

    // Create new
    $maxPartNo++;
    $uid = 'P' . str_pad($maxPartNo, 6, '0', STR_PAD_LEFT);

    $partsCache[$part_name] = [
        'unique_part_id' => $uid,
        'tally_part'     => 1
    ];

    $newParts[] = [
        'unique_part_id' => $uid,
        'part_name'      => $part_name
    ];

    return $uid;
}

/* --------------------------------------------------
   LOAD FULL JSON (SAFE FOR YOUR SERVER)
-------------------------------------------------- */
$json = file_get_contents($inputFile);
if ($json === false) {
    die("❌ Cannot read JSON file");
}

$data = json_decode($json, true);
if (!$data) {
    die("❌ JSON decode failed");
}

$stockItems =& find_stock_items($data);
if (empty($stockItems)) {
    die("❌ StockItem array not found");
}

/* --------------------------------------------------
   PREPARE BATCH ARRAYS
-------------------------------------------------- */
$newParts     = [];
$tallyUpdates = [];

/* --------------------------------------------------
   PROCESS EACH STOCK ITEM
-------------------------------------------------- */
foreach ($stockItems as &$item) {

    if (!isset($item['Name'])) continue;

    // MAIN PART
    $item['unique_part_id'] =
        get_or_create_unique_part_id_cached(
            $item['Name'],
            $partsCache,
            $maxPartNo,
            $newParts,
            $tallyUpdates
        );

    // BOM
    if (!empty($item['MULTICOMPONENTLIST'])) {

        foreach ($item['MULTICOMPONENTLIST'] as &$component) {

            if (!empty($component['MULTICOMPONENTITEMLIST'])) {

                foreach ($component['MULTICOMPONENTITEMLIST'] as &$child) {

                    if (!empty($child['StockItemName'])) {

                        $child['unique_part_id'] =
                            get_or_create_unique_part_id_cached(
                                $child['StockItemName'],
                                $partsCache,
                                $maxPartNo,
                                $newParts,
                                $tallyUpdates
                            );
                    }
                }
            }
        }
    }
}

/* --------------------------------------------------
   BATCH INSERT NEW PARTS (ONCE)
-------------------------------------------------- */
if (!empty($newParts)) {

    $values = [];
    foreach ($newParts as $p) {
        $name = $conn->real_escape_string($p['part_name']);
        $uid  = $p['unique_part_id'];
        $values[] = "('$uid','$name',1)";
    }

    $sql = "
        INSERT IGNORE INTO parts_tbl (unique_part_id, part_name, tally_part)
        VALUES " . implode(',', $values);

    if (!$conn->query($sql)) {
        die("SQL ERROR (INSERT PARTS): " . $conn->error);
    }
}

/* --------------------------------------------------
   BATCH UPDATE tally_part (ONCE)
-------------------------------------------------- */
if (!empty($tallyUpdates)) {

    $names = array_map(
        fn($n) => "'" . $conn->real_escape_string($n) . "'",
        array_keys($tallyUpdates)
    );

    $sql = "
        UPDATE parts_tbl
        SET tally_part = 1
        WHERE part_name IN (" . implode(',', $names) . ")
    ";

    if (!$conn->query($sql)) {
        die("SQL ERROR (UPDATE tally_part): " . $conn->error);
    }
}

/* --------------------------------------------------
   WRITE ENRICHED JSON
-------------------------------------------------- */
file_put_contents(
    $outputFile,
    json_encode(
        $data,
        JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES
    )
);

echo "✅ SUCCESS: Enriched JSON created (shared hosting safe)\n";
$conn->close();