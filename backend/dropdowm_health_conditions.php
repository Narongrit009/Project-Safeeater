<?php
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
include "./conn.php";

// Query ข้อมูลจากตาราง health_conditions
$sql = "SELECT * FROM health_conditions";
$result = $conn->query($sql);

$data = array();
if ($result->num_rows > 0) {
    // ข้อมูลหลายแถว
    while ($row = $result->fetch_assoc()) {
        $data[] = $row;
    }
} else {
    echo json_encode(array("message" => "0 results"));
}

echo json_encode($data);

// ปิดการเชื่อมต่อ
$conn->close();
