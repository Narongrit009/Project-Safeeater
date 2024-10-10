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

// Query เพื่อคำนวณจำนวนเมนูในแต่ละหมวดหมู่
$sql = "SELECT fc.category_name, COUNT(fm.menu_id) AS total_menus
        FROM food_categories fc
        LEFT JOIN food_menu fm ON fc.id = fm.category_id
        GROUP BY fc.category_name";

$result = $conn->query($sql);

$categories = array();
if ($result->num_rows > 0) {
    while ($row = $result->fetch_assoc()) {
        $categories[] = array(
            'category_name' => $row['category_name'],
            'total_menus' => $row['total_menus'],
        );
    }

    echo json_encode([
        'success' => true,
        'data' => $categories,
    ]);
} else {
    echo json_encode([
        'success' => false,
        'message' => 'ไม่พบข้อมูลหมวดหมู่เมนู',
    ]);
}

// ปิดการเชื่อมต่อกับฐานข้อมูล
$conn->close();
