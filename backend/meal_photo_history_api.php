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
            mph.history_id,
						mi.menu_id,
						mi.menu_name,
						mi.image_url,
						mi.ingredient_list,
						mi.disease_list,
            mph.is_edible,
            mph.created_at
        FROM
            meal_photo_history mph
        JOIN
            users u ON mph.user_id = u.user_id
				JOIN
            food_photo_menu mi ON mph.menu_id = mi.menu_id
        WHERE
            u.email = ?
        ORDER BY
            mph.created_at DESC;
    ");

    $user_query->bind_param("s", $email);
    $user_query->execute();
    $result = $user_query->get_result();

    if ($result->num_rows > 0) {
        $rows = [];
        while ($row = $result->fetch_assoc()) {
            // สร้าง URL เต็มรูปแบบสำหรับ image_url
            $row['image_url'] = "http://" . $_SERVER['HTTP_HOST'] . "/safeeater/uploads/photos/" . $row['image_url'];
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
