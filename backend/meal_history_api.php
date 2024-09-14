<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST, GET, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type");
header('Content-Type: application/json');

include "./conn.php";

// รับข้อมูล JSON จากการร้องขอ
$data = json_decode(file_get_contents('php://input'), true);

if (isset($data['email']) && !empty($data['email'])) {
    $email = $data['email'];

    // ดึงข้อมูลผู้ใช้จาก email
    $user_query = $conn->prepare("
        SELECT
            mh.history_id,
            u.email,
            fm.menu_name,
            mh.meal_time,
            mh.is_edible,
            fm.image_url
        FROM
            meal_history mh
        JOIN
            users u ON mh.user_id = u.user_id
        JOIN
            food_menu fm ON mh.menu_id = fm.menu_id
        WHERE
            u.email = ?
        ORDER BY
            mh.meal_time DESC
    ");

    $user_query->bind_param("s", $email);
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
