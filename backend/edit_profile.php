<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST, GET, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type");
header('Content-Type: application/json');

include "./conn.php";

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    if (isset($_POST['email']) && !empty($_POST['email']) &&
        isset($_POST['username']) && isset($_POST['tel']) && isset($_POST['gender']) &&
        isset($_POST['birthday']) && isset($_POST['height']) &&
        isset($_POST['weight']) && isset($_POST['food_allergies']) &&
        isset($_POST['chronic_diseases'])) {

        $email = $_POST['email'];
        $username = $_POST['username'];
        $tel = $_POST['tel'];
        $gender = $_POST['gender'];
        $birthday = $_POST['birthday'];
        $height = $_POST['height'];
        $weight = $_POST['weight'];
        $new_food_allergies = $_POST['food_allergies'];
        $new_chronic_diseases = $_POST['chronic_diseases'];

        // เริ่มต้นการอัปเดตข้อมูล
        $conn->begin_transaction();

        try {
            // ตรวจสอบว่ามีรูปภาพถูกส่งมาหรือไม่
            if (isset($_FILES['photo']) && $_FILES['photo']['size'] > 0) {
                // จัดการอัปโหลดรูปภาพ
                $photo = $_FILES['photo'];
                $upload_dir = 'profile/photos/';

                // ตรวจสอบชนิดไฟล์ที่อนุญาต
                $allowed_extensions = ['jpg', 'jpeg', 'png', 'gif'];
                $photo_extension = pathinfo($photo['name'], PATHINFO_EXTENSION);

                if (!in_array(strtolower($photo_extension), $allowed_extensions)) {
                    echo json_encode(['status' => 'error', 'message' => 'Invalid file type. Only JPG, PNG, and GIF are allowed.']);
                    exit;
                }

                // สร้างชื่อไฟล์ใหม่สำหรับรูปภาพ
                $photo_name = 'photo_' . time() . '.' . $photo_extension;
                $photo_path = $upload_dir . $photo_name;

                // ย้ายไฟล์รูปภาพไปยังโฟลเดอร์ที่ต้องการ
                if (!move_uploaded_file($photo['tmp_name'], $photo_path)) {
                    throw new Exception("Failed to upload the image.");
                }

                // อัปเดตข้อมูลผู้ใช้ในตาราง users พร้อมรูปภาพ
                $update_user_query = $conn->prepare("
                    UPDATE users SET username = ?, tel = ?, gender = ?, birthday = ?, height = ?, weight = ?, image_url = ?
                    WHERE email = ?
                ");
                $update_user_query->bind_param("ssssssss", $username, $tel, $gender, $birthday, $height, $weight, $photo_name, $email);
            } else {
                // อัปเดตข้อมูลผู้ใช้ในตาราง users โดยไม่มีรูปภาพ
                $update_user_query = $conn->prepare("
                    UPDATE users SET username = ?, tel = ?, gender = ?, birthday = ?, height = ?, weight = ?
                    WHERE email = ?
                ");
                $update_user_query->bind_param("sssssss", $username, $tel, $gender, $birthday, $height, $weight, $email);
            }

            $update_user_query->execute();
            $update_user_query->close();

            // ตรวจสอบและอัปเดตข้อมูล allergies ถ้ามีการเปลี่ยนแปลง
            $current_allergies_query = $conn->prepare("
            SELECT GROUP_CONCAT(ni.ingredient_name ORDER BY ni.ingredient_name SEPARATOR ', ') AS food_allergies
            FROM users_allergies ua
            JOIN nutritional_information ni ON ua.nutrition_id = ni.ingredient_id
            WHERE ua.user_id = (SELECT user_id FROM users WHERE email = ?)
        ");
            $current_allergies_query->bind_param("s", $email);
            $current_allergies_query->execute();
            $current_allergies_result = $current_allergies_query->get_result();
            $current_allergies_row = $current_allergies_result->fetch_assoc();
            $current_food_allergies = $current_allergies_row['food_allergies'];
            $current_allergies_query->close();

            if ($new_food_allergies !== $current_food_allergies) {
                // ลบข้อมูล allergies เดิมออก
                $delete_allergies_query = $conn->prepare("DELETE FROM users_allergies WHERE user_id = (SELECT user_id FROM users WHERE email = ?)");
                $delete_allergies_query->bind_param("s", $email);
                $delete_allergies_query->execute();
                $delete_allergies_query->close();

                // เพิ่มข้อมูล allergies ใหม่
                $allergies = explode(', ', $new_food_allergies);
                foreach ($allergies as $allergy) {
                    $insert_allergy_query = $conn->prepare("
                    INSERT INTO users_allergies (user_id, nutrition_id)
                    SELECT u.user_id, ni.ingredient_id
                    FROM users u, nutritional_information ni
                    WHERE u.email = ? AND ni.ingredient_name = ?
                ");
                    $insert_allergy_query->bind_param("ss", $email, $allergy);
                    $insert_allergy_query->execute();
                    $insert_allergy_query->close();
                }
            }

            // ตรวจสอบและอัปเดตข้อมูล conditions ถ้ามีการเปลี่ยนแปลง
            $current_conditions_query = $conn->prepare("
            SELECT GROUP_CONCAT(hc.condition_name ORDER BY hc.condition_name SEPARATOR ', ') AS chronic_diseases
            FROM users_health_conditions uhc
            JOIN health_conditions hc ON uhc.condition_id = hc.condition_id
            WHERE uhc.user_id = (SELECT user_id FROM users WHERE email = ?)
        ");
            $current_conditions_query->bind_param("s", $email);
            $current_conditions_query->execute();
            $current_conditions_result = $current_conditions_query->get_result();
            $current_conditions_row = $current_conditions_result->fetch_assoc();
            $current_chronic_diseases = $current_conditions_row['chronic_diseases'];
            $current_conditions_query->close();

            if ($new_chronic_diseases !== $current_chronic_diseases) {
                // ลบข้อมูล conditions เดิมออก
                $delete_conditions_query = $conn->prepare("DELETE FROM users_health_conditions WHERE user_id = (SELECT user_id FROM users WHERE email = ?)");
                $delete_conditions_query->bind_param("s", $email);
                $delete_conditions_query->execute();
                $delete_conditions_query->close();

                // เพิ่มข้อมูล conditions ใหม่
                $conditions = explode(', ', $new_chronic_diseases);
                foreach ($conditions as $condition) {
                    $insert_condition_query = $conn->prepare("
                    INSERT INTO users_health_conditions (user_id, condition_id)
                    SELECT u.user_id, hc.condition_id
                    FROM users u, health_conditions hc
                    WHERE u.email = ? AND hc.condition_name = ?
                ");
                    $insert_condition_query->bind_param("ss", $email, $condition);
                    $insert_condition_query->execute();
                    $insert_condition_query->close();
                }
            }

            // ยืนยันการทำธุรกรรม
            $conn->commit();
            echo json_encode(["status" => "success", "message" => "ข้อมูลถูกอัปเดตแล้ว"]);
        } catch (Exception $e) {
            $conn->rollback();
            echo json_encode(["status" => "error", "message" => "ไม่สามารถอัปเดตข้อมูลได้: " . $e->getMessage()]);
        }
    } else {
        echo json_encode(["status" => "error", "message" => "Invalid input"]);
    }
}

$conn->close();
