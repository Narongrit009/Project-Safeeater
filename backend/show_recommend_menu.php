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
        SELECT fm.menu_id, fm.menu_name, fc.category_name, fm.image_url
        FROM food_menu fm
        LEFT JOIN food_categories fc ON fm.category_id = fc.id
        LEFT JOIN health_conditions hc ON fm.health_menu_recommend = hc.condition_id
        WHERE hc.condition_id IN (
            SELECT uhc.condition_id
            FROM users_health_conditions uhc
            LEFT JOIN users ON uhc.user_id = users.user_id
            WHERE email = ?
        );
    ");

    $user_query->bind_param("s", $email);
    $user_query->execute();
    $result = $user_query->get_result();

    if ($result->num_rows > 0) {
        $rows = [];
        while ($row = $result->fetch_assoc()) {
            // แปลง menu_id เป็น int
            $row['menu_id'] = (int) $row['menu_id'];
            $rows[] = $row;
        }
        echo json_encode(["status" => "success", "data" => $rows]);
    } else {
        // ถ้าไม่เจอข้อมูลจาก query แรก ใช้ query สำรอง
        $fallback_query = "
            SELECT fm.menu_id, fm.menu_name, fc.category_name, fm.image_url
            FROM food_menu fm
            LEFT JOIN food_categories fc ON fm.category_id = fc.id
            LEFT JOIN health_conditions hc ON fm.health_menu_recommend = hc.condition_id
            WHERE hc.condition_id != 0;
        ";

        $fallback_result = $conn->query($fallback_query);

        if ($fallback_result->num_rows > 0) {
            $rows = [];
            while ($row = $fallback_result->fetch_assoc()) {
                // แปลง menu_id เป็น int ใน query สำรองด้วย
                $row['menu_id'] = (int) $row['menu_id'];
                $rows[] = $row;
            }
            echo json_encode(["status" => "success", "data" => $rows]);
        } else {
            echo json_encode(["status" => "error", "message" => "No menu available"]);
        }
    }

    $user_query->close();
} else {
    echo json_encode(["status" => "error", "message" => "Invalid input"]);
}

$conn->close();
