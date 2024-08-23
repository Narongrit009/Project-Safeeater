<?php
header('Access-Control-Allow-Origin: *');
include "./conn.php";

// รับค่าจากแบบฟอร์มที่ส่งมา
$email = isset($_REQUEST['email']) ? $_REQUEST['email'] : '';
$password = isset($_REQUEST['password']) ? $_REQUEST['password'] : '';
$phone = isset($_REQUEST['phone']) ? $_REQUEST['phone'] : '';

// ตรวจสอบว่า email และ password ไม่ว่างเปล่า
if (!empty($email) && !empty($password)) {
    // เตรียมคำสั่ง SQL
    $stmt = $conn->prepare("INSERT INTO `users` (`email`, `password`, `tel`) VALUES (?, ?, ?)");
    $stmt->bind_param("sss", $email, $password, $phone);

    if ($stmt->execute()) {
        // ส่งรหัสสถานะ 200 (OK)
        http_response_code(200);
        echo json_encode(['status' => 'success', 'message' => 'User added successfully.']);
    } else {
        // ส่งรหัสสถานะ 500 (Internal Server Error) หากมีข้อผิดพลาดในการเพิ่มข้อมูล
        http_response_code(500);
        echo json_encode(['status' => 'error', 'message' => 'Error: ' . $stmt->error]);
    }

    // ปิด statement
    $stmt->close();
} else {
    // ส่งรหัสสถานะ 400 (Bad Request) หากไม่มีข้อมูล
    http_response_code(400);
    echo json_encode(['status' => 'error', 'message' => 'Email and password are required.']);
}

// ปิดการเชื่อมต่อกับฐานข้อมูล
mysqli_close($conn);
