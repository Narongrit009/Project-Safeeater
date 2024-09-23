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
        u.user_id,
        u.username,
        u.email,
        u.tel,
        u.gender,
        u.birthday,
        u.height,
        u.weight,
        u.image_url,
        IFNULL(GROUP_CONCAT(DISTINCT hc.condition_name ORDER BY hc.condition_name ASC SEPARATOR ', '), 'ไม่มี') AS chronic_diseases,
        IFNULL(GROUP_CONCAT(DISTINCT ni.ingredient_name ORDER BY ni.ingredient_name ASC SEPARATOR ', '), 'ไม่มี') AS food_allergies
    FROM
        users u
    LEFT JOIN
        users_health_conditions uhc ON u.user_id = uhc.user_id
    LEFT JOIN
        health_conditions hc ON uhc.condition_id = hc.condition_id
    LEFT JOIN
        users_allergies ua ON u.user_id = ua.user_id
    LEFT JOIN
        nutritional_information ni ON ua.nutrition_id = ni.ingredient_id
    WHERE
        u.email = ?
    GROUP BY
        u.user_id;
    ");

    $user_query->bind_param("s", $email);
    $user_query->execute();
    $result = $user_query->get_result();

    if ($result->num_rows > 0) {
        $row = $result->fetch_assoc();

        // สร้าง URL สำหรับรูปภาพโปรไฟล์
        if (!empty($row['image_url'])) {
            $image_url = "http://" . $_SERVER['HTTP_HOST'] . "/safeeater/profile/photos/" . $row['image_url'];
        } else {
            $image_url = null; // หรือใส่ URL ของรูปภาพเริ่มต้น
        }

        // รวม image_url ในข้อมูลที่ส่งกลับ
        $row['image_url'] = $image_url;

        echo json_encode(["status" => "success", "data" => $row]);
    } else {
        echo json_encode(["status" => "error", "message" => "User not found"]);
    }

    $user_query->close();
} else {
    echo json_encode(["status" => "error", "message" => "Invalid input"]);
}

$conn->close();
