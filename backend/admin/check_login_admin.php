<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST, GET, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type");
header('Content-Type: application/json');

// เชื่อมต่อกับฐานข้อมูล
include "../conn.php";

// รับข้อมูล JSON ที่ส่งเข้ามา
$data = json_decode(file_get_contents('php://input'), true);

$email = $data['email'];
$password = $data['password'];

// ตรวจสอบว่ามีข้อมูลอีเมลและรหัสผ่านในฐานข้อมูลหรือไม่
$query = "SELECT * FROM admin_accounts WHERE email = ? AND password = ?";
$stmt = $conn->prepare($query);
$stmt->bind_param("ss", $email, $password);
$stmt->execute();
$result = $stmt->get_result();

if ($result->num_rows > 0) {
    // ผู้ใช้ที่เข้าสู่ระบบสำเร็จ
    $user = $result->fetch_assoc();
    echo json_encode(array(
        "status" => "success",
        "message" => "Login successful",
        "email" => $user['email'],
    ));
} else {
    // ผู้ใช้ที่เข้าสู่ระบบไม่สำเร็จ
    echo json_encode(array(
        "status" => "error",
        "message" => "Invalid email or password",
    ));
}

$stmt->close();
$conn->close();
