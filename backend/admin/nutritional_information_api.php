<?php
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Access-Control-Allow-Headers, Authorization, X-Requested-With');

include "../conn.php"; // นำเข้าไฟล์เชื่อมต่อฐานข้อมูล

// รับค่า request method
$requestMethod = $_SERVER['REQUEST_METHOD'];

switch ($requestMethod) {
    case 'GET':
        // ดึงข้อมูลทั้งหมดจากตาราง nutritional_information
        $sql = "SELECT * FROM nutritional_information";
        $result = $conn->query($sql);

        $ingredients = array();
        if ($result && $result->num_rows > 0) {
            while ($row = $result->fetch_assoc()) {
                $ingredients[] = $row;
            }
            echo json_encode($ingredients);
        } else {
            echo json_encode(['status' => 'error', 'message' => 'No ingredients found']);
        }
        break;

    case 'POST':
        // เพิ่มข้อมูลใหม่
        $data = json_decode(file_get_contents("php://input"), true);
        $ingredient_name = trim($data['ingredient_name']);
        $calories = $data['calories'];
        $quantity_per_unit = $data['quantity_per_unit'];
        $protein = $data['protein'];
        $fat = $data['fat'];
        $carbohydrates = $data['carbohydrates'];
        $dietary_fiber = $data['dietary_fiber'];
        $calcium = $data['calcium'];
        $iron = $data['iron'];
        $vitamin_c = $data['vitamin_c'];
        $sodium = $data['sodium'];
        $sugar = $data['sugar'];
        $cholesterol = $data['cholesterol'];
        $image_url = trim($data['image_url']);

        if (!empty($ingredient_name)) {
            // หาค่า ingredient_id ล่าสุด
            $getMaxIdSql = "SELECT MAX(ingredient_id) as max_id FROM nutritional_information";
            $maxIdResult = $conn->query($getMaxIdSql);
            $maxIdRow = $maxIdResult->fetch_assoc();
            $newIngredientId = $maxIdRow['max_id'] + 1;

            // เพิ่มข้อมูลใหม่โดยใช้ ingredient_id ที่เพิ่มขึ้น
            $sql = "INSERT INTO nutritional_information (ingredient_id, ingredient_name, calories, quantity_per_unit, protien, fat, carbohydrates, dietary_fiber, calcium, iron, vitamin_c, sodium, sugar, cholesterol, image_url, created_at)
                        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, NOW())";
            $stmt = $conn->prepare($sql);
            $stmt->bind_param('isddddddddddsss', $newIngredientId, $ingredient_name, $calories, $quantity_per_unit, $protein, $fat, $carbohydrates, $dietary_fiber, $calcium, $iron, $vitamin_c, $sodium, $sugar, $cholesterol, $image_url);

            if ($stmt->execute()) {
                echo json_encode(['status' => 'success', 'message' => 'Ingredient added successfully']);
            } else {
                // แสดงข้อผิดพลาดจากฐานข้อมูล
                echo json_encode(['status' => 'error', 'message' => 'Failed to add ingredient', 'error' => $stmt->error]);
            }
            $stmt->close();
        } else {
            echo json_encode(['status' => 'error', 'message' => 'Invalid input: Ingredient name is required']);
        }
        break;

    case 'PUT':
        // แก้ไขข้อมูล
        $data = json_decode(file_get_contents("php://input"), true);
        $ingredient_id = $data['ingredient_id'];
        $ingredient_name = trim($data['ingredient_name']);
        $calories = $data['calories'];
        $quantity_per_unit = $data['quantity_per_unit'];
        $protien = $data['protien']; // เปลี่ยนเป็น protien ให้ตรงกับชื่อคอลัมน์ในฐานข้อมูล
        $fat = $data['fat'];
        $carbohydrates = $data['carbohydrates'];
        $dietary_fiber = $data['dietary_fiber'];
        $calcium = $data['calcium'];
        $iron = $data['iron'];
        $vitamin_c = $data['vitamin_c'];
        $sodium = $data['sodium'];
        $sugar = $data['sugar'];
        $cholesterol = $data['cholesterol'];
        $image_url = trim($data['image_url']);

        if (!empty($ingredient_id) && !empty($ingredient_name)) {
            $sql = "UPDATE nutritional_information SET ingredient_name = ?, calories = ?, quantity_per_unit = ?, protien = ?, fat = ?, carbohydrates = ?, dietary_fiber = ?, calcium = ?, iron = ?, vitamin_c = ?, sodium = ?, sugar = ?, cholesterol = ?, image_url = ? WHERE ingredient_id = ?";
            $stmt = $conn->prepare($sql);
            $stmt->bind_param('sddddddddddsssi', $ingredient_name, $calories, $quantity_per_unit, $protien, $fat, $carbohydrates, $dietary_fiber, $calcium, $iron, $vitamin_c, $sodium, $sugar, $cholesterol, $image_url, $ingredient_id);

            if ($stmt->execute()) {
                echo json_encode(['status' => 'success', 'message' => 'Ingredient updated successfully']);
            } else {
                // แสดงข้อผิดพลาดจากฐานข้อมูลเพื่อการดีบัก
                echo json_encode(['status' => 'error', 'message' => 'Failed to update ingredient', 'error' => $stmt->error, 'sql_error' => $conn->error]);
            }
            $stmt->close();
        } else {
            echo json_encode(['status' => 'error', 'message' => 'Invalid input: Ingredient ID and name are required']);
        }
        break;

    case 'DELETE':
        // ลบข้อมูล
        $data = json_decode(file_get_contents("php://input"), true);

        // รับค่า ingredient_id จาก body ที่ส่งมาผ่าน axios
        if (isset($data['id'])) {
            $ingredient_id = $data['id'];

            // Debugging: Log the received ID for deletion
            error_log("Received ID for deletion: " . $ingredient_id);

            $sql = "DELETE FROM nutritional_information WHERE ingredient_id = ?";
            $stmt = $conn->prepare($sql);
            $stmt->bind_param('i', $ingredient_id);

            if ($stmt->execute()) {
                echo json_encode(['status' => 'success', 'message' => 'Ingredient deleted successfully']);
            } else {
                error_log("Database error: " . $stmt->error);
                echo json_encode(['status' => 'error', 'message' => 'Failed to delete ingredient']);
            }
            $stmt->close();
        } else {
            error_log("Invalid input: ID not received");
            echo json_encode(['status' => 'error', 'message' => 'Invalid input']);
        }
        break;

    case 'OPTIONS':
        // จัดการ preflight request สำหรับ CORS
        http_response_code(200);
        break;

    default:
        echo json_encode(['status' => 'error', 'message' => 'Invalid request method']);
        break;
}

// ปิดการเชื่อมต่อฐานข้อมูล
$conn->close();
