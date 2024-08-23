<?php
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
include "./conn.php";

// ดึงข้อมูล
$sql = "SELECT * FROM nutritional_information";
$result = $conn->query($sql);

$nutritional_info = array();
if ($result->num_rows > 0) {
    while ($row = $result->fetch_assoc()) {
        $nutritional_info[] = $row;
    }
}

// ส่งข้อมูลกลับเป็น JSON
echo json_encode($nutritional_info);

// ปิดการเชื่อมต่อ
$conn->close();
