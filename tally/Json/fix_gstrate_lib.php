<?php
/**
 * GST FIX LIBRARY (OPTIMIZED)
 */

function fix_gstrate_from_enriched_json(mysqli $conn, string $jsonFile): int
{
    static $gstCache = []; // LEVEL-3 cache

    $json = file_get_contents($jsonFile);
    if (!$json) return 0;

    $data = json_decode($json, true);
    if (!$data || empty($data['StockItem'])) return 0;

    $today = strtotime(date('Y-m-d'));
    $updated = 0;

    // LEVEL-1: transaction
    $conn->begin_transaction();

    foreach ($data['StockItem'] as $item) {

        if (empty($item['unique_part_id'])) {
            continue;
        }

        $uid = $conn->real_escape_string($item['unique_part_id']);

        // LEVEL-3: reuse GST if cached
        if (isset($gstCache[$uid])) {
            $gstrate = $gstCache[$uid];
        } else {

            $gstrate = 0;

            if (!empty($item['GSTDETAILS']) && is_array($item['GSTDETAILS'])) {

                $validSlabs = [];

                foreach ($item['GSTDETAILS'] as $gst) {

                    if (empty($gst['APPLICABLEFROM'])) continue;

                    $appliedOn = strtotime($gst['APPLICABLEFROM']);

                    // ignore future slabs
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

                        $cgst = 0;
                        $sgst = 0;
                        $igst = 0;

                        foreach ($latest['STATEWISEDETAILS'][0]['RATEDETAILS'] as $rate) {

                            $head = strtoupper(trim($rate['GSTRATEDUTYHEAD'] ?? ''));
                            $val  = (float)($rate['GSTRATE'] ?? 0);

                            if ($head === 'IGST') {
                                $igst = $val;
                            } elseif ($head === 'CGST') {
                                $cgst = $val;
                            } elseif ($head === 'SGST/UTGST' || $head === 'SGST') {
                                $sgst = $val;
                            }
                        }

                        $gstrate = ($igst > 0)
                            ? (int)$igst
                            : (int)($cgst + $sgst);
                    }
                }
            }

            // save in cache
            $gstCache[$uid] = $gstrate;
        }

        // LEVEL-2: skip if same value
        $sql = "
            UPDATE parts_tbl
            SET gstrate = $gstrate
            WHERE unique_part_id = '$uid'
              AND gstrate <> $gstrate
        ";

        if ($conn->query($sql)) {
            $updated++;
        }
    }

    $conn->commit();

    return $updated;
}
