<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST, GET, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Authorization");
require_once 'vendor/autoload.php'; // ใช้ Guzzle ถ้าจำเป็น

header('Content-Type: application/json');

include "./conn.php";

// รับข้อมูลจากคำขอ POST
$phoneNumber = $_POST['phone_number'] ?? '';
$newPassword = $_POST['new_password'] ?? '';

if (empty($phoneNumber) || empty($newPassword)) {
    echo json_encode(['status' => 'error', 'message' => 'Phone number and new password are required.']);
    exit;
}

// เข้ารหัสรหัสผ่านใหม่
$hashedPassword = password_hash($newPassword, PASSWORD_BCRYPT);

// ตรวจสอบว่ามีเบอร์โทรศัพท์ในระบบหรือไม่
$sql = "SELECT * FROM users WHERE tel = ?";
$stmt = $conn->prepare($sql);
$stmt->bind_param('s', $phoneNumber);
$stmt->execute();
$result = $stmt->get_result();

if ($result->num_rows > 0) {
    // ถ้าพบข้อมูล ให้ทำการอัปเดตรหัสผ่าน
    $updateSql = "UPDATE users SET password = ? WHERE tel = ?";
    $updateStmt = $conn->prepare($updateSql);
    $updateStmt->bind_param('ss', $hashedPassword, $phoneNumber);

    if ($updateStmt->execute()) {
        echo json_encode(['status' => 'success', 'message' => 'Password updated successfully.']);
    } else {
        echo json_encode(['status' => 'error', 'message' => 'Failed to update password.']);
    }
    $updateStmt->close();
} else {
    echo json_encode(['status' => 'error', 'message' => 'Phone number not found.']);
}

$stmt->close();
$conn->close();
