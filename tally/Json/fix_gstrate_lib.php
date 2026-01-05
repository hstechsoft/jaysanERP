<?php
/**
 * GST FIX LIBRARY
 * Do NOT run directly
 */

function fix_gstrate_from_enriched_json(mysqli $conn, string $jsonFile): int
{
    $json = file_get_contents($jsonFile);
    if (!$json) return 0;

    $data = json_decode($json, true);
    if (!$data || empty($data['StockItem'])) return 0;

    $today = strtotime(date('Y-m-d'));
    $updated = 0;

    foreach ($data['StockItem'] as $item) {

        if (empty($item['unique_part_id']) || empty($item['GSTDETAILS'])) {
            continue;
        }

        $uid = $conn->real_escape_string($item['unique_part_id']);
        $gstrate = 0;

        // ---- GST LOGIC (FINAL) ----
        $validSlabs = [];

        foreach ($item['GSTDETAILS'] as $gst) {
            if (empty($gst['APPLICABLEFROM'])) continue;

            $appliedOn = strtotime($gst['APPLICABLEFROM']);
            if ($appliedOn !== false && $appliedOn <= time()) {
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

        // ---- UPDATE ----
        $sql = "
            UPDATE parts_tbl
            SET gstrate = $gstrate
            WHERE unique_part_id = '$uid'
        ";

        if ($conn->query($sql)) {
            $updated++;
        }
    }

    return $updated;
}
