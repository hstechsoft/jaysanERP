<?php
if (session_status() === PHP_SESSION_NONE) {
    session_start();
}

$current_file = basename($_SERVER['PHP_SELF']);
echo session_status(); 

/* Public files (no session required) */
$public_files = [
    'login.php',
    'logout.php'
];

if (!in_array($current_file, $public_files)) {
    if (!isset($_SESSION['user_id'])) {
        http_response_code(401);
        exit;
    }
}

echo $current_file;
header('Location: login.html'); 
?>
