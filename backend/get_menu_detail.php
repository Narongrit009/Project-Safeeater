<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST, GET, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type");
header('Content-Type: application/json');

include "./conn.php";

// รับข้อมูล JSON จากการร้องขอ
$data = json_decode(file_get_contents('php://input'), true);

if (isset($data['menu_id']) && !empty($data['menu_id'])) {
    $menu_id = $data['menu_id'];

    // ดึงข้อมูลผู้ใช้จาก email
    $user_query = $conn->prepare("
        SELECT
    fm.menu_name,
    fm.image_url,
    GROUP_CONCAT(DISTINCT ni.ingredient_name SEPARATOR ', ') AS ingredients,
    GROUP_CONCAT(DISTINCT ni.ingredient_id SEPARATOR ', ') AS ingredients_id,
    GROUP_CONCAT(DISTINCT ni.image_url SEPARATOR ', ') AS ingredients_image,
    GROUP_CONCAT(DISTINCT hc.condition_name ORDER BY fhr.condition_id SEPARATOR ', ') AS related_conditions,
    GROUP_CONCAT(DISTINCT hc.condition_description ORDER BY fhr.condition_id SEPARATOR ', ') AS related_conditions_detail
FROM
    food_menu fm
LEFT JOIN
    menu_nutritional_information mni ON fm.menu_id = mni.menu_id
LEFT JOIN
    nutritional_information ni ON mni.ingredient_id = ni.ingredient_id
LEFT JOIN
    food_health_relation fhr ON fm.menu_id = fhr.menu_id
LEFT JOIN
    health_conditions hc ON fhr.condition_id = hc.condition_id
WHERE
    fm.menu_id = ?
GROUP BY
    fm.menu_id, fm.menu_name, fm.image_url;

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
