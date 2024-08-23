<?php
error_reporting(E_ALL);
ini_set('display_errors', 1);

header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST, GET, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type");
header('Content-Type: application/json');

include "./conn.php";

// รับข้อมูล JSON จากการร้องขอ
$data = json_decode(file_get_contents('php://input'), true);

if (isset($data['email']) && !empty($data['email'])) {
    $email = $data['email'];

    // ดึง user_id จาก email
    $user_id_query = $conn->prepare("SELECT user_id FROM users WHERE email = ?");
    if (!$user_id_query) {
        echo json_encode(["status" => "error", "message" => "Prepare failed: " . $conn->error]);
        exit();
    }

    $user_id_query->bind_param("s", $email);
    $user_id_query->execute();
    $result = $user_id_query->get_result();

    if ($result->num_rows > 0) {
        $row = $result->fetch_assoc();
        $user_id = $row['user_id'];

        // ฟังก์ชันสำหรับการเพิ่มข้อมูลการแพ้อาหาร
        function insert_food_allergies($conn, $user_id, $food_allergies)
        {
            foreach ($food_allergies as $allergy) {
                $ingredient_query = $conn->prepare("SELECT ingredient_id FROM nutritional_information WHERE ingredient_name = ?");
                if (!$ingredient_query) {
                    echo json_encode(["status" => "error", "message" => "Prepare failed: " . $conn->error]);
                    exit();
                }

                $ingredient_query->bind_param("s", $allergy);
                $ingredient_query->execute();
                $ingredient_result = $ingredient_query->get_result();

                if ($ingredient_result->num_rows > 0) {
                    $ingredient_row = $ingredient_result->fetch_assoc();
                    $ingredient_id = $ingredient_row['ingredient_id'];

                    $allergy_insert_query = $conn->prepare("INSERT INTO users_allergies (user_id, nutrition_id) VALUES (?, ?)");
                    if (!$allergy_insert_query) {
                        echo json_encode(["status" => "error", "message" => "Prepare failed: " . $conn->error]);
                        exit();
                    }

                    $allergy_insert_query->bind_param("ii", $user_id, $ingredient_id);
                    if (!$allergy_insert_query->execute()) {
                        echo json_encode(["status" => "error", "message" => "Failed to insert food allergy data: " . $allergy_insert_query->error]);
                        exit();
                    }
                } else {
                    echo json_encode(["status" => "error", "message" => "Ingredient not found: $allergy"]);
                    exit();
                }
            }
        }

        // ฟังก์ชันสำหรับการเพิ่มข้อมูลโรคเรื้อรัง
        function insert_chronic_diseases($conn, $user_id, $chronic_diseases)
        {
            foreach ($chronic_diseases as $disease) {
                $condition_query = $conn->prepare("SELECT condition_id FROM health_conditions WHERE condition_name = ?");
                if (!$condition_query) {
                    echo json_encode(["status" => "error", "message" => "Prepare failed: " . $conn->error]);
                    exit();
                }

                $condition_query->bind_param("s", $disease);
                $condition_query->execute();
                $condition_result = $condition_query->get_result();

                if ($condition_result->num_rows > 0) {
                    $condition_row = $condition_result->fetch_assoc();
                    $condition_id = $condition_row['condition_id'];

                    $disease_insert_query = $conn->prepare("INSERT INTO users_health_conditions (user_id, condition_id) VALUES (?, ?)");
                    if (!$disease_insert_query) {
                        echo json_encode(["status" => "error", "message" => "Prepare failed: " . $conn->error]);
                        exit();
                    }

                    $disease_insert_query->bind_param("ii", $user_id, $condition_id);
                    if (!$disease_insert_query->execute()) {
                        echo json_encode(["status" => "error", "message" => "Failed to insert chronic disease data: " . $disease_insert_query->error]);
                        exit();
                    }
                } else {
                    echo json_encode(["status" => "error", "message" => "Condition not found: $disease"]);
                    exit();
                }
            }
        }

        // Insert ข้อมูลโรคและการแพ้อาหาร
        if (isset($data['food_allergies']) && !empty($data['food_allergies'])) {
            insert_food_allergies($conn, $user_id, $data['food_allergies']);
        }

        if (isset($data['chronic_diseases']) && !empty($data['chronic_diseases'])) {
            insert_chronic_diseases($conn, $user_id, $data['chronic_diseases']);
        }

        // อัปเดตข้อมูลผู้ใช้
        if (isset($data['height'], $data['weight'], $data['birth_date'], $data['gender'], $data['username']) &&
            !empty($data['height']) && !empty($data['weight']) && !empty($data['birth_date']) && !empty($data['gender']) && !empty($data['username'])) {

            $height = $data['height'];
            $weight = $data['weight'];
            $birth_date = $data['birth_date'];
            $gender = $data['gender'];
            $username = $data['username'];

            $user_query = $conn->prepare("UPDATE users SET height = ?, weight = ?, birthday = ?, gender = ?, username = ? WHERE user_id = ?");
            if (!$user_query) {
                echo json_encode(["status" => "error", "message" => "Prepare failed: " . $conn->error]);
                exit();
            }

            $user_query->bind_param("issssi", $height, $weight, $birth_date, $gender, $username, $user_id);
            if (!$user_query->execute()) {
                echo json_encode(["status" => "error", "message" => "Failed to update user data: " . $user_query->error]);
                exit();
            } else {
                echo json_encode(["status" => "success", "message" => "User data updated successfully"]);
            }
        } else {
            echo json_encode(["status" => "error", "message" => "Invalid user data"]);
            exit();
        }

    } else {
        echo json_encode(["status" => "error", "message" => "User not found"]);
        exit();
    }

    $user_id_query->close();
} else {
    echo json_encode(["status" => "error", "message" => "Invalid input"]);
    exit();
}

$conn->close();
