<?php
/**
 * FIX GST RATE FROM ENRICHED JSON
 * Safe, accurate, ERP-grade
 */

include __DIR__ . '/../../php/db_head.php';

ini_set('memory_limit', '1024M');
set_time_limit(0);

$jsonFile = 'stock_enriched.json';

$json = file_get_contents($jsonFile);
if (!$json) {
    die("❌ Cannot read stock_enriched.json");
}

$data = json_decode($json, true);
if (!$data || empty($data['StockItem'])) {
    die("❌ Invalid JSON");
}

$today = strtotime(date('Y-m-d'));
$updated = 0;

foreach ($data['StockItem'] as $item) {

    if (empty($item['unique_part_id']) || empty($item['GSTDETAILS'])) {
        continue;
    }

    $uid = $conn->real_escape_string($item['unique_part_id']);
    $gstrate = 0;

    // ---- GST LOGIC (FINAL & CORRECT) ----
    $validSlabs = [];

    foreach ($item['GSTDETAILS'] as $gst) {

        if (empty($gst['APPLICABLEFROM'])) continue;

        $appliedOn = strtotime($gst['APPLICABLEFROM']);
        if ($appliedOn !== false && $appliedOn <= $today) {
            $validSlabs[] = [
                'date' => $appliedOn,
                'data' => $gst
            ];
        }
    }

    if (!empty($validSlabs)) {

        usort($validSlabs, fn($a, $b) => $b['date'] <=> $a['date']);
        $latest = $validSlabs[0]['data'];

        if (!empty($latest['STATEWISEDETAILS'][0]['RATEDETAILS'])) {

            $cgst = 0; $sgst = 0; $igst = 0;

            foreach ($latest['STATEWISEDETAILS'][0]['RATEDETAILS'] as $rate) {

                $head = strtoupper(trim($rate['GSTRATEDUTYHEAD'] ?? ''));
                $val  = (float)($rate['GSTRATE'] ?? 0);

                if ($head === 'IGST') $igst = $val;
                elseif ($head === 'CGST') $cgst = $val;
                elseif ($head === 'SGST/UTGST' || $head === 'SGST') $sgst = $val;
            }

            $gstrate = ($igst > 0) ? (int)$igst : (int)($cgst + $sgst);
        }
    }

    // ---- UPDATE DB ----
    $sql = "
        UPDATE parts_tbl
        SET gstrate = $gstrate
        WHERE unique_part_id = '$uid'
    ";

    if ($conn->query($sql)) {
        $updated++;
    }
}

echo "✅ GST FIX COMPLETED. Updated rows: $updated\n";
