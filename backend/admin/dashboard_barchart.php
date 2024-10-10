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

// ดึงจำนวนผู้ใช้ที่มีโรคประจำตัวแต่ละโรค
$bar_chart_query = "
    SELECT hc.condition_name, COUNT(uhc.user_id) as total_users
    FROM health_conditions hc
    LEFT JOIN users_health_conditions uhc ON hc.condition_id = uhc.condition_id
    GROUP BY hc.condition_name
";
$result = $conn->query($bar_chart_query);

$bar_chart_data = [];
while ($row = $result->fetch_assoc()) {
    $bar_chart_data[] = [
        'condition_name' => $row['condition_name'],
        'total_users' => $row['total_users'],
    ];
}

// ส่งข้อมูลกลับเป็น JSON
echo json_encode([
    'success' => true,
    'data' => $bar_chart_data,
]);

// ปิดการเชื่อมต่อฐานข้อมูล
$conn->close();
