<?php
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');

include "../conn.php"; // เชื่อมต่อฐานข้อมูล

// ตรวจสอบการเชื่อมต่อฐานข้อมูล
if ($conn->connect_error) {
    echo json_encode([
        'success' => false,
        'message' => 'เชื่อมต่อฐานข้อมูลล้มเหลว: ' . $conn->connect_error,
    ]);
    exit();
}

// จำนวนผู้ใช้
$user_count_query = "SELECT COUNT(*) as total_users FROM users";
$user_count_result = $conn->query($user_count_query);
$user_count = $user_count_result->fetch_assoc()['total_users'];

// จำนวนเมนูอาหาร
$food_menu_count_query = "SELECT COUNT(*) as total_food_menu FROM food_menu";
$food_menu_count_result = $conn->query($food_menu_count_query);
$food_menu_count = $food_menu_count_result->fetch_assoc()['total_food_menu'];

// จำนวนวัตถุดิบ
$ingredients_count_query = "SELECT COUNT(*) as total_ingredients FROM nutritional_information";
$ingredients_count_result = $conn->query($ingredients_count_query);
$ingredients_count = $ingredients_count_result->fetch_assoc()['total_ingredients'];

// จำนวนโรค (ไม่นับโรคที่ชื่อว่า 'ไม่มี')
$diseases_count_query = "SELECT COUNT(*) as total_diseases FROM health_conditions WHERE condition_name != 'ไม่มี'";
$diseases_count_result = $conn->query($diseases_count_query);
$diseases_count = $diseases_count_result->fetch_assoc()['total_diseases'];

// ส่งข้อมูลกลับเป็น JSON
echo json_encode([
    'success' => true,
    'data' => [
        'total_users' => $user_count,
        'total_food_menu' => $food_menu_count,
        'total_ingredients' => $ingredients_count,
        'total_diseases' => $diseases_count,
    ],
]);

// ปิดการเชื่อมต่อฐานข้อมูล
$conn->close();
