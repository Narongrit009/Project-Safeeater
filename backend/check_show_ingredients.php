<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST, GET, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type");
header('Content-Type: application/json');

include "./conn.php";

// รับข้อมูล JSON จากการร้องขอ
$data = json_decode(file_get_contents('php://input'), true);

if (isset($data['ingredients']) && is_array($data['ingredients']) && !empty($data['ingredients'])) {
    $ingredients = $data['ingredients'];
    $output = [];

    foreach ($ingredients as $ingredient) {
        $ingredient = trim($ingredient);

        // แยกคำในวัตถุดิบเพื่อทำการค้นหาให้ยืดหยุ่นมากขึ้น
        // เช่น "หมูสับ" จะได้คำว่า ["หมู", "สับ"]
        $keywords = preg_split('/\s+/', $ingredient);

        // สร้างคำสั่ง SQL โดยใช้ OR เพื่อค้นหาคำที่คล้ายกัน
        $likeClauses = [];
        $params = [];
        foreach ($keywords as $word) {
            $likeClauses[] = "ingredient_name LIKE ?";
            $params[] = '%' . $word . '%';
        }
        $sql = "SELECT ingredient_id, ingredient_name, image_url FROM nutritional_information WHERE " . implode(' OR ', $likeClauses) . " LIMIT 1"; // จำกัดผลลัพธ์ให้แสดง 1 ข้อมูล

        $stmt = $conn->prepare($sql);

        // ประกอบประเภทของพารามิเตอร์เพื่อใช้กับ bind_param
        $paramTypes = str_repeat('s', count($params));
        $stmt->bind_param($paramTypes, ...$params);

        $stmt->execute();
        $result = $stmt->get_result();

        if ($row = $result->fetch_assoc()) {
            $output[] = $row;
        }
    }

    // ส่งผลลัพธ์ในรูปแบบ JSON
    echo json_encode($output);
} else {
    // ส่งค่าผลลัพธ์เป็นอาร์เรย์ว่าง ๆ หากไม่มีข้อมูลที่ถูกต้อง
    echo json_encode([]);
}

$conn->close();
