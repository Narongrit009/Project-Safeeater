<?php
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: DELETE, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type');

// เช็คว่าเป็นคำขอแบบ OPTIONS (สำหรับ CORS preflight requests)
if ($_SERVER['REQUEST_METHOD'] == 'OPTIONS') {
    exit(0); // ส่งกลับ response 200 OK และสิ้นสุดการประมวลผล
}

include "../conn.php"; // เชื่อมต่อกับฐานข้อมูล

// ตรวจสอบการเชื่อมต่อกับฐานข้อมูล
if ($conn->connect_error) {
    echo json_encode([
        'success' => false,
        'message' => 'การเชื่อมต่อฐานข้อมูลล้มเหลว: ' . $conn->connect_error,
    ]);
    exit();
}

// อ่านข้อมูล JSON ที่ส่งมาใน request body
$data = json_decode(file_get_contents("php://input"), true);

// ตรวจสอบว่ามีข้อมูล menu_id หรือไม่
if (!isset($data['menu_id'])) {
    echo json_encode([
        'success' => false,
        'message' => 'ไม่มีข้อมูลเมนูที่ต้องการลบ',
    ]);
    exit();
}

$menuId = $data['menu_id'];

try {
    // เริ่ม transaction เพื่อความปลอดภัยในการลบข้อมูลหลายตาราง
    $conn->begin_transaction();

    // ลบข้อมูลโรคที่เกี่ยวข้องจากตาราง food_health_relation
    $deleteRelatedConditions = $conn->prepare("DELETE FROM food_health_relation WHERE menu_id = ?");
    if (!$deleteRelatedConditions) {
        throw new Exception("Error preparing delete statement for related conditions: " . $conn->error);
    }
    $deleteRelatedConditions->bind_param("i", $menuId);
    $deleteRelatedConditions->execute();

    // ลบข้อมูลวัตถุดิบจากตาราง menu_nutritional_information
    $deleteIngredients = $conn->prepare("DELETE FROM menu_nutritional_information WHERE menu_id = ?");
    if (!$deleteIngredients) {
        throw new Exception("Error preparing delete statement for ingredients: " . $conn->error);
    }
    $deleteIngredients->bind_param("i", $menuId);
    $deleteIngredients->execute();

    // ลบข้อมูลเมนูจากตาราง food_menu
    $deleteMenu = $conn->prepare("DELETE FROM food_menu WHERE menu_id = ?");
    if (!$deleteMenu) {
        throw new Exception("Error preparing delete statement for menu: " . $conn->error);
    }
    $deleteMenu->bind_param("i", $menuId);
    $deleteMenu->execute();

    // Commit transaction
    $conn->commit();

    echo json_encode([
        'success' => true,
        'message' => 'ลบเมนูอาหารเรียบร้อยแล้ว',
    ]);

} catch (Exception $e) {
    // Rollback transaction ถ้ามีข้อผิดพลาดเกิดขึ้น
    $conn->rollback();
    error_log($e->getMessage()); // บันทึกข้อความผิดพลาดลงใน log ของเซิร์ฟเวอร์
    echo json_encode([
        'success' => false,
        'message' => 'เกิดข้อผิดพลาด: ' . $e->getMessage(),
    ]);
}

// ปิดการเชื่อมต่อฐานข้อมูล
$conn->close();
