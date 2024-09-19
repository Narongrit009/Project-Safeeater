<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST, GET, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type");
header('Content-Type: application/json');

include "./conn.php";

// ตรวจสอบ method ว่าเป็น POST หรือไม่
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    // รับข้อมูล JSON จาก request body
    $data = json_decode(file_get_contents('php://input'), true);

    // ตรวจสอบว่าได้รับข้อมูลที่จำเป็นหรือไม่
    if (isset($data['user_id'], $data['menu_id'], $data['is_edible'])) {
        $user_id = intval($data['user_id']);
        $menu_id = intval($data['menu_id']);
        $is_edible = $data['is_edible'];

        // เตรียมคำสั่ง SQL เพื่อ insert ข้อมูลเข้าไปในตาราง meal_photo_history
        $sql = "INSERT INTO meal_photo_history (user_id, menu_id, is_edible, created_at)
                VALUES (?, ?, ?, NOW())";

        if ($stmt = $conn->prepare($sql)) {
            $stmt->bind_param('iis', $user_id, $menu_id, $is_edible);

            // ตรวจสอบการทำงานของคำสั่ง SQL
            if ($stmt->execute()) {
                echo json_encode(['status' => 'success', 'message' => 'Meal photo history saved successfully.'], JSON_UNESCAPED_UNICODE);
            } else {
                echo json_encode(['status' => 'error', 'message' => 'Failed to save meal photo history.'], JSON_UNESCAPED_UNICODE);
            }

            $stmt->close();
        } else {
            echo json_encode(['status' => 'error', 'message' => 'Database error.']);
        }
    } else {
        echo json_encode(['status' => 'error', 'message' => 'Invalid input data.']);
    }
} else {
    echo json_encode(['status' => 'error', 'message' => 'Invalid request method.']);
}

// ปิดการเชื่อมต่อฐานข้อมูล
$conn->close();
