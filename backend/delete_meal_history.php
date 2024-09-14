<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST, DELETE");
header("Access-Control-Allow-Headers: Content-Type");
header('Content-Type: application/json');

include "./conn.php";

// รับข้อมูล JSON จากการร้องขอ
$data = json_decode(file_get_contents('php://input'), true);

// ตรวจสอบว่ามีข้อมูล ID ของรายการที่ต้องการลบ
if (isset($data['history_ids']) && is_array($data['history_ids'])) {
    $history_ids = $data['history_ids'];

    // ตรวจสอบว่ามีรายการใน array หรือไม่
    if (count($history_ids) > 0) {
        // แปลง array เป็น string เพื่อใช้ใน SQL query
        $placeholders = implode(',', array_fill(0, count($history_ids), '?'));

        // เตรียม SQL เพื่อทำการลบรายการที่ตรงกับ history_ids
        $delete_query = $conn->prepare("DELETE FROM meal_history WHERE history_id IN ($placeholders)");

        // สร้าง array ที่จะ bind ค่า
        $types = str_repeat('i', count($history_ids)); // ใช้ 'i' (integer) เนื่องจาก history_id เป็นตัวเลข
        $delete_query->bind_param($types, ...$history_ids);

        // ดำเนินการลบรายการ
        if ($delete_query->execute()) {
            echo json_encode(["status" => "success", "message" => "ลบรายการสำเร็จ"]);
        } else {
            echo json_encode(["status" => "error", "message" => "เกิดข้อผิดพลาดในการลบรายการ"]);
        }

        $delete_query->close();
    } else {
        echo json_encode(["status" => "error", "message" => "ไม่มีรายการที่ต้องลบ"]);
    }
} else {
    echo json_encode(["status" => "error", "message" => "ข้อมูลไม่ถูกต้อง"]);
}

$conn->close();
