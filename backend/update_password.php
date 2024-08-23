<?php
header("Access-Control-Allow-Origin: *"); // Allow requests from any origin
header("Access-Control-Allow-Methods: POST, GET, OPTIONS"); // Allow these HTTP methods
header("Access-Control-Allow-Headers: Content-Type, Authorization"); // Allow these headers
require_once 'vendor/autoload.php';

header('Content-Type: application/json');

include "./conn.php";

// ดึงข้อมูลจากคำขอ POST
$email = $_POST['email'] ?? '';
$newPassword = $_POST['new_password'] ?? '';

if (empty($email) || empty($newPassword)) {
    echo json_encode(['status' => 'error', 'message' => 'Email and new password are required.']);
    exit;
}

// เข้ารหัสรหัสผ่านใหม่
$hashedPassword = password_hash($newPassword, PASSWORD_BCRYPT);

// อัพเดทฐานข้อมูล
$sql = "UPDATE users SET password = ? WHERE email = ?";
$stmt = $conn->prepare($sql);
$stmt->bind_param('ss', $hashedPassword, $email);

if ($stmt->execute()) {
    echo json_encode(['status' => 'success', 'message' => 'Password updated successfully.']);
} else {
    echo json_encode(['status' => 'error', 'message' => 'Failed to update password.']);
}

$stmt->close();
$conn->close();
