<?php
header("Access-Control-Allow-Origin: *"); // Allow requests from any origin
header("Access-Control-Allow-Methods: POST, GET, OPTIONS"); // Allow these HTTP methods
header("Access-Control-Allow-Headers: Content-Type, Authorization"); // Allow headers like content type and authorization
header('Content-Type: application/json'); // Set content type to JSON

require_once 'vendor/autoload.php'; // Load Composer autoloader if using GuzzleHttp

use GuzzleHttp\Client;

// ตรวจสอบว่ามีการส่งค่า token และ otp มาหรือไม่
$token = $_POST['token'] ?? '';
$otp = $_POST['otp'] ?? '';

if (empty($token) || empty($otp)) {
    echo json_encode([
        'status' => 'error',
        'message' => 'Token or OTP is missing.',
    ]);
    exit();
}

$client = new Client();

try {
    // ส่งคำร้องขอไปยัง API เพื่อทำการตรวจสอบ OTP
    $response = $client->post('https://otp.thaibulksms.com/v2/otp/verify', [
        'form_params' => [
            'key' => '1810927327004233', // ใช้ App Key ของคุณ
            'secret' => '36c97e742c2a4e7eb05a850ac88b396e', // ใช้ App Secret ของคุณ
            'token' => $token, // ใช้ token จากการส่ง OTP
            'pin' => $otp, // ใช้ otp ที่ได้รับจากผู้ใช้
        ],
    ]);

    $body = $response->getBody();
    $statusCode = $response->getStatusCode();

    if ($statusCode == 200) {
        // ตรวจสอบว่าการตอบกลับจาก API สำเร็จหรือไม่
        $result = json_decode($body, true);
        if ($result['status'] == 'success') {
            echo json_encode([
                'status' => 'success',
                'message' => 'OTP verified successfully.',
            ]);
        } else {
            echo json_encode([
                'status' => 'error',
                'message' => $result['message'] ?? 'Failed to verify OTP.',
            ]);
        }
    } else {
        // ถ้าการตอบกลับจาก API ไม่ใช่ 200 ให้ส่ง error กลับไป
        echo json_encode([
            'status' => 'error',
            'message' => 'Failed to verify OTP. API returned error.',
        ]);
    }

} catch (Exception $e) {
    // กรณีที่เกิดข้อผิดพลาดระหว่างการติดต่อ API
    echo json_encode([
        'status' => 'error',
        'message' => 'Failed to verify OTP. ' . $e->getMessage(),
    ]);
}
