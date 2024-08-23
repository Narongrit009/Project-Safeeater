<?php
header("Access-Control-Allow-Origin: *"); // Allow requests from any origin
header("Access-Control-Allow-Methods: POST, GET, OPTIONS"); // Allow these HTTP methods
header("Access-Control-Allow-Headers: Content-Type, Authorization"); // Allow these headers

require_once 'vendor/autoload.php';

use GuzzleHttp\Client;

$client = new Client();

try {
    $response = $client->post('https://otp.thaibulksms.com/v2/otp/verify', [
        'form_params' => [
            'key' => '1804943408015789', // Your App Key
            'secret' => '02c43ecbc0ff9c6261c1288e73171c4d', // Your App Secret
            'token' => $_POST['token'], // Token from the request
            'pin' => $_POST['pin'], // OTP received from SMS
        ],
    ]);

    $body = $response->getBody();
    echo $body;
} catch (Exception $e) {
    echo json_encode(['status' => 'error', 'message' => 'Failed to verify OTP. ' . $e->getMessage()]);
}
