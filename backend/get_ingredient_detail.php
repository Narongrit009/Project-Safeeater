<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST, GET, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type");
header('Content-Type: application/json');

include "./conn.php";

// รับข้อมูล JSON จากการร้องขอ
$data = json_decode(file_get_contents('php://input'), true);

if (isset($data['ingredients_name']) && !empty($data['ingredients_name'])) {
    $menu_id = $data['ingredients_name'];

    // ดึงข้อมูลผู้ใช้จาก email
    $user_query = $conn->prepare("
        SELECT *
FROM nutritional_information
WHERE ingredient_name = ?
    ");

    $user_query->bind_param("s", $menu_id);
    $user_query->execute();
    $result = $user_query->get_result();

    if ($result->num_rows > 0) {
        $rows = [];
        while ($row = $result->fetch_assoc()) {
            $rows[] = $row;
        }
        echo json_encode(["status" => "success", "data" => $rows]);
    } else {
        echo json_encode(["status" => "error", "message" => "User not found or no meal history"]);
    }

    $user_query->close();
} else {
    echo json_encode(["status" => "error", "message" => "Invalid input"]);
}

$conn->close();
