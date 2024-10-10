<?php
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET');
header('Access-Control-Allow-Headers: Content-Type');

include "../conn.php"; // เชื่อมต่อกับฐานข้อมูล

// ตรวจสอบการเชื่อมต่อกับฐานข้อมูล
if ($conn->connect_error) {
    echo json_encode([
        'success' => false,
        'message' => 'การเชื่อมต่อฐานข้อมูลล้มเหลว: ' . $conn->connect_error,
    ]);
    exit();
}

// ตรวจสอบว่ามีการส่งค่า menu_id มาใน URL หรือไม่
if (!isset($_GET['menu_id'])) {
    echo json_encode([
        'success' => false,
        'message' => 'ไม่มีการส่งค่า menu_id',
    ]);
    exit();
}

$menu_id = $_GET['menu_id'];

// เตรียมคำสั่ง SQL
$query = "
    SELECT
        fm.menu_name,
				fc.category_name,
				hcc.condition_name,
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
		LEFT JOIN
        health_conditions hcc ON fm.health_menu_recommend = hcc.condition_id
		LEFT JOIN
        food_categories fc ON fm.category_id = fc.id
    WHERE
        fm.menu_id = ?
    GROUP BY
        fm.menu_id, fm.menu_name, fm.image_url
";

// เตรียมและดำเนินการ statement
$stmt = $conn->prepare($query);
if (!$stmt) {
    echo json_encode([
        'success' => false,
        'message' => 'Error preparing statement: ' . $conn->error,
    ]);
    exit();
}

$stmt->bind_param("i", $menu_id);

if (!$stmt->execute()) {
    echo json_encode([
        'success' => false,
        'message' => 'Error executing query: ' . $stmt->error,
    ]);
    exit();
}

$result = $stmt->get_result();
$data = $result->fetch_assoc();

if ($data) {
    echo json_encode([
        'success' => true,
        'data' => $data,
    ]);
} else {
    echo json_encode([
        'success' => false,
        'message' => 'ไม่พบข้อมูลเมนูที่ระบุ',
    ]);
}

// ปิดการเชื่อมต่อฐานข้อมูล
$stmt->close();
$conn->close();
