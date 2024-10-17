<?php
header("Access-Control-Allow-Origin: *"); // Allow requests from any origin
header("Access-Control-Allow-Methods: POST, GET, OPTIONS"); // Allow specific methods
header("Access-Control-Allow-Headers: Content-Type, Authorization");
require_once 'vendor/autoload.php';

use GuzzleHttp\Client;

header('Content-Type: application/json');

// ดึงข้อมูลจากคำขอ POST
$phoneNumber = $_POST['phone_number'] ?? '';
$apiKey = '1813135969829444'; // แทนที่ด้วย App Key ของคุณ
$apiSecret = '12a43021c2b93df3cdbefc1de8218504'; // แทนที่ด้วย App Secret ของคุณ

if (empty($phoneNumber)) {
    echo json_encode(['status' => 'error', 'message' => 'Phone number is required.']);
    exit;
}

$client = new Client();
$response = $client->request('POST', 'https://otp.thaibulksms.com/v2/otp/request', [
    'form_params' => [
        'key' => $apiKey,
        'secret' => $apiSecret,
        'msisdn' => $phoneNumber,
    ],
    'headers' => [
        'accept' => 'application/json',
        'content-type' => 'application/x-www-form-urlencoded',
    ],
]);

$body = $response->getBody();
$statusCode = $response->getStatusCode();

if ($statusCode == 200) {
    echo $body;
} else {
    echo json_encode(['status' => 'error', 'message' => 'Failed to send OTP.']);
}
