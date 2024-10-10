<?php
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: PUT');
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
    !isset($data['menu_id']) ||
    !isset($data['menu_name']) ||
    !isset($data['category']) ||
    !isset($data['image_url']) ||
    !isset($data['health_condition']) ||
    !isset($data['ingredients']) ||
    !is_array($data['ingredients']) ||
    !isset($data['related_conditions']) ||
    !is_array($data['related_conditions'])
) {
    echo json_encode([
        'success' => false,
        'message' => 'ข้อมูลไม่ครบถ้วน',
    ]);
    exit();
}

$menuId = $data['menu_id'];
$menuName = $data['menu_name'];
$categoryId = $data['category'];
$imageUrl = $data['image_url'];
$healthConditionId = $data['health_condition'];
$ingredients = $data['ingredients'];
$relatedConditions = $data['related_conditions'];

// กำหนดค่า health_menu_recommend เป็น null หาก health_condition = 0
$healthMenuRecommend = ($healthConditionId != 0) ? $healthConditionId : null;

try {
    // เริ่ม transaction เพื่อความปลอดภัยของการอัปเดตหลายตาราง
    $conn->begin_transaction();

    // อัปเดตข้อมูลในตาราง food_menu
    $stmt = $conn->prepare("UPDATE food_menu SET menu_name = ?, category_id = ?, image_url = ?, health_menu_recommend = ? WHERE menu_id = ?");
    if (!$stmt) {
        throw new Exception("Error preparing statement: " . $conn->error);
    }
    $stmt->bind_param("sissi", $menuName, $categoryId, $imageUrl, $healthMenuRecommend, $menuId);
    if (!$stmt->execute()) {
        throw new Exception("Error executing statement: " . $stmt->error);
    }

    // ลบข้อมูลวัตถุดิบที่มีอยู่ก่อนในตาราง menu_nutritional_information
    $deleteIngredients = $conn->prepare("DELETE FROM menu_nutritional_information WHERE menu_id = ?");
    if (!$deleteIngredients) {
        throw new Exception("Error preparing delete statement for ingredients: " . $conn->error);
    }
    $deleteIngredients->bind_param("i", $menuId);
    $deleteIngredients->execute();

    // เพิ่มข้อมูลวัตถุดิบใหม่
    $stmtIngredients = $conn->prepare("INSERT INTO menu_nutritional_information (menu_id, ingredient_id) VALUES (?, ?)");
    if (!$stmtIngredients) {
        throw new Exception("Error preparing ingredients statement: " . $conn->error);
    }
    foreach ($ingredients as $ingredientId) {
        $stmtIngredients->bind_param("ii", $menuId, $ingredientId);
        if (!$stmtIngredients->execute()) {
            throw new Exception("Error executing ingredients statement: " . $stmtIngredients->error);
        }
    }

    // ลบข้อมูลโรคที่เกี่ยวข้องที่มีอยู่ก่อนในตาราง food_health_relation
    $deleteRelatedConditions = $conn->prepare("DELETE FROM food_health_relation WHERE menu_id = ?");
    if (!$deleteRelatedConditions) {
        throw new Exception("Error preparing delete statement for related conditions: " . $conn->error);
    }
    $deleteRelatedConditions->bind_param("i", $menuId);
    $deleteRelatedConditions->execute();

    // เพิ่มข้อมูลโรคที่เกี่ยวข้องใหม่
    if (!empty($relatedConditions)) {
        $stmtRelatedConditions = $conn->prepare("INSERT INTO food_health_relation (menu_id, condition_id) VALUES (?, ?)");
        if (!$stmtRelatedConditions) {
            throw new Exception("Error preparing related conditions statement: " . $conn->error);
        }
        foreach ($relatedConditions as $conditionId) {
            if ($conditionId != 0) {
                $stmtRelatedConditions->bind_param("ii", $menuId, $conditionId);
                if (!$stmtRelatedConditions->execute()) {
                    throw new Exception("Error executing related conditions statement: " . $stmtRelatedConditions->error);
                }
            }
        }
    }

    // Commit transaction
    $conn->commit();

    echo json_encode([
        'success' => true,
        'message' => 'แก้ไขข้อมูลเมนูอาหารเรียบร้อยแล้ว',
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
