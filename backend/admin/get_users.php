<?php
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
include "../conn.php";

// ดึงข้อมูล
$sql = "SELECT
        u.user_id,
        u.username,
        u.email,
        u.tel,
        u.gender,
        u.birthday,
        u.height,
        u.weight,
        u.image_url,
        IFNULL(GROUP_CONCAT(DISTINCT hc.condition_name ORDER BY hc.condition_name ASC SEPARATOR ', '), 'ไม่มี') AS chronic_diseases,
        IFNULL(GROUP_CONCAT(DISTINCT ni.ingredient_name ORDER BY ni.ingredient_name ASC SEPARATOR ', '), 'ไม่มี') AS food_allergies
    FROM
        users u
    LEFT JOIN
        users_health_conditions uhc ON u.user_id = uhc.user_id
    LEFT JOIN
        health_conditions hc ON uhc.condition_id = hc.condition_id
    LEFT JOIN
        users_allergies ua ON u.user_id = ua.user_id
    LEFT JOIN
        nutritional_information ni ON ua.nutrition_id = ni.ingredient_id
    GROUP BY
        u.user_id;";

$result = $conn->query($sql);

$users = array();
if ($result->num_rows > 0) {
    while ($row = $result->fetch_assoc()) {
        // ตรวจสอบว่า image_url มีค่าไหม
        if (!empty($row['image_url'])) {
            $image_url = "http://" . $_SERVER['HTTP_HOST'] . "/safeeater/profile/photos/" . $row['image_url'];
        } else {
            $image_url = null; // กรณีที่ไม่มีรูปภาพ
        }

        // เพิ่มข้อมูลของผู้ใช้รวมถึง image_url เข้าไปในอาร์เรย์
        $users[] = array(
            'user_id' => $row['user_id'],
            'username' => $row['username'],
            'email' => $row['email'],
            'tel' => $row['tel'],
            'gender' => $row['gender'],
            'birthday' => $row['birthday'],
            'height' => $row['height'],
            'weight' => $row['weight'],
            'image_url' => $image_url, // ส่ง URL รูปภาพกลับไป
            'chronic_diseases' => $row['chronic_diseases'],
            'food_allergies' => $row['food_allergies'],
        );
    }
}

// ส่งข้อมูลกลับเป็น JSON
echo json_encode($users);

// ปิดการเชื่อมต่อ
$conn->close();
