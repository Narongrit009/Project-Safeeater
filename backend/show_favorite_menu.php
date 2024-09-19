<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST, GET, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type");
header('Content-Type: application/json');

include "./conn.php";

// รับข้อมูล JSON จากการร้องขอ
$data = json_decode(file_get_contents('php://input'), true);

// ตรวจสอบว่ามี email ส่งมาหรือไม่
if (isset($data['email']) && !empty($data['email'])) {
    $email = $data['email'];

    // คำสั่ง SQL เพื่อดึงข้อมูลรายการโปรดของผู้ใช้
    $sql = "
    SELECT
        ff.id,
        ff.user_id,
        ff.food_id,
        ff.menu_id,
        ff.is_favorite,
        fm.image_url AS image_food,
        fpm.image_url AS image_foodphoto,
        fm.menu_name AS food_menu_name,
        fpm.menu_name AS food_photo_menu_name
    FROM
        favorite_food ff
    JOIN
        users u ON ff.user_id = u.user_id
    LEFT JOIN
        food_menu fm ON ff.food_id = fm.menu_id
    LEFT JOIN
        food_photo_menu fpm ON ff.menu_id = fpm.menu_id
    WHERE
        ff.is_favorite = 'true' AND u.email = ?
    ORDER BY
        ff.updated_at DESC
    ";

    // เตรียมและประมวลผลคำสั่ง SQL
    if ($stmt = $conn->prepare($sql)) {
        $stmt->bind_param("s", $email);
        $stmt->execute();
        $result = $stmt->get_result();

        if ($result->num_rows > 0) {
            $menus = [];
            while ($row = $result->fetch_assoc()) {
                // ตรวจสอบว่าเป็น image_food หรือ image_foodphoto และสร้าง URL ที่ถูกต้อง
                if ($row['image_foodphoto']) {
                    $image_url = "http://" . $_SERVER['HTTP_HOST'] . "/safeeater/uploads/photos/" . $row['image_foodphoto'];
                    $menu_type = 'photo'; // กำหนดว่าเป็นเมนูรูปถ่าย
                } else {
                    $image_url = $row['image_food'];
                    $menu_type = 'meal'; // กำหนดว่าเป็นเมนูอาหารทั่วไป
                }

                $menu_name = $row['food_menu_name'] ? $row['food_menu_name'] : $row['food_photo_menu_name'];

                // เก็บข้อมูลเมนูใน array
                $menus[] = [
                    'menu_id' => $row['food_id'] ? $row['food_id'] : $row['menu_id'], // ใช้ menu_id จาก food_menu หรือ food_photo_menu
                    'menu_name' => $menu_name,
                    'image_url' => $image_url,
                    'is_favorite' => $row['is_favorite'],
                    'menu_type' => $menu_type, // เพิ่มฟิลด์ menu_type เพื่อตรวจสอบว่าเป็น photo หรือ meal
                ];
            }

            echo json_encode([
                "status" => "success",
                "data" => $menus,
            ]);
        } else {
            echo json_encode(["status" => "error", "message" => "ไม่พบรายการโปรด"]);
        }

        $stmt->close();
    } else {
        echo json_encode(["status" => "error", "message" => "ไม่สามารถเตรียมคำสั่ง SQL ได้"]);
    }
} else {
    echo json_encode(["status" => "error", "message" => "ไม่มีข้อมูล email"]);
}

// ปิดการเชื่อมต่อฐานข้อมูล
$conn->close();
