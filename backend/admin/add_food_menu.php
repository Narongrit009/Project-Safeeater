<?php
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST');
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

// อ่านข้อมูล JSON ที่ส่งมาใน request body
$data = json_decode(file_get_contents("php://input"), true);

// ตรวจสอบว่ามีข้อมูลที่จำเป็นครบถ้วนหรือไม่
if (
    !isset($data['menu_name']) ||
    !isset($data['category']) ||
    !isset($data['image_url']) ||
    !isset($data['health_condition']) ||
    !isset($data['ingredients']) ||
    !is_array($data['ingredients']) ||
    !isset($data['related_conditions']) || // ตรวจสอบ related_conditions
    !is_array($data['related_conditions'])
) {
    echo json_encode([
        'success' => false,
        'message' => 'ข้อมูลไม่ครบถ้วน',
    ]);
    exit();
}

$menuName = $data['menu_name'];
$categoryId = $data['category'];
$imageUrl = $data['image_url'];
$healthConditionId = $data['health_condition'];
$ingredients = $data['ingredients'];
$relatedConditions = $data['related_conditions']; // ดึงข้อมูลโรคที่เกี่ยวข้อง

// กำหนดค่า health_menu_recommend เป็น null หาก health_condition = 0
$healthMenuRecommend = ($healthConditionId != 0) ? $healthConditionId : null;

try {
    // เริ่ม transaction เพื่อความปลอดภัยของการ insert หลายตาราง
    $conn->begin_transaction();

    // ดึง menu_id ล่าสุดจากตาราง food_menu แล้วเพิ่ม 1 เพื่อใช้เป็น menu_id ใหม่
    $result = $conn->query("SELECT MAX(menu_id) AS max_menu_id FROM food_menu");
    if (!$result) {
        throw new Exception("Error fetching max menu_id: " . $conn->error);
    }
    $row = $result->fetch_assoc();
    $newMenuId = $row['max_menu_id'] + 1;

    // เพิ่มข้อมูลลงในตาราง food_menu พร้อมกับกำหนด menu_id และ health_menu_recommend
    $stmt = $conn->prepare("INSERT INTO food_menu (menu_id, menu_name, category_id, image_url, health_menu_recommend) VALUES (?, ?, ?, ?, ?)");
    if (!$stmt) {
        throw new Exception("Error preparing statement: " . $conn->error);
    }
    $stmt->bind_param("isiss", $newMenuId, $menuName, $categoryId, $imageUrl, $healthMenuRecommend);
    if (!$stmt->execute()) {
        throw new Exception("Error executing statement: " . $stmt->error);
    }

    // เพิ่มข้อมูลวัตถุดิบที่เกี่ยวข้องลงในตาราง menu_nutritional_information
    $stmtIngredients = $conn->prepare("INSERT INTO menu_nutritional_information (menu_id, ingredient_id) VALUES (?, ?)");
    if (!$stmtIngredients) {
        throw new Exception("Error preparing ingredients statement: " . $conn->error);
    }
    foreach ($ingredients as $ingredientId) {
        $stmtIngredients->bind_param("ii", $newMenuId, $ingredientId);
        if (!$stmtIngredients->execute()) {
            throw new Exception("Error executing ingredients statement: " . $stmtIngredients->error);
        }
    }

    // เพิ่มข้อมูลโรคที่เกี่ยวข้องลงในตาราง food_health_relation
    $stmtRelatedConditions = $conn->prepare("INSERT INTO food_health_relation (menu_id, condition_id) VALUES (?, ?)");
    if (!$stmtRelatedConditions) {
        throw new Exception("Error preparing related conditions statement: " . $conn->error);
    }

    foreach ($relatedConditions as $conditionId) {
        if ($conditionId != 0) { // ตรวจสอบว่าค่า conditionId ไม่เป็น 0
            $stmtRelatedConditions->bind_param("ii", $newMenuId, $conditionId);
            if (!$stmtRelatedConditions->execute()) {
                throw new Exception("Error executing related conditions statement: " . $stmtRelatedConditions->error);
            }
        }
    }

    // Commit transaction
    $conn->commit();

    echo json_encode([
        'success' => true,
        'message' => 'เพิ่มเมนูอาหารและโรคที่เกี่ยวข้องเรียบร้อยแล้ว',
        'menu_id' => $newMenuId,
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
