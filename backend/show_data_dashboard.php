<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST, GET, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type");
header('Content-Type: application/json');

include "./conn.php";

// รับข้อมูล JSON จากการร้องขอ
$data = json_decode(file_get_contents('php://input'), true);
date_default_timezone_set('Asia/Bangkok'); // ตั้งค่า timezone

// ตรวจสอบว่ามี email และ filter ส่งมาหรือไม่
if (isset($data['email']) && !empty($data['email'])) {
    $email = $data['email'];
    $filter = isset($data['filter']) ? $data['filter'] : 'week'; // รับ filter จาก frontend (ถ้าไม่ส่งมาใช้ค่า default เป็น 'week')
    $nutrient = isset($data['nutrient']) ? $data['nutrient'] : 'sugar'; // รับ nutrient จาก frontend (ถ้าไม่ส่งมาใช้ค่า default เป็น 'sugar')

    // กำหนดวันที่เริ่มต้นและสิ้นสุดตาม filter
    $startDate = '';
    $endDate = date('Y-m-d'); // สิ้นสุดที่วันที่ปัจจุบัน

    if ($filter === 'week') {
        // ถ้าตัวกรองเป็นสัปดาห์ ให้คำนวณวันที่เริ่มต้นย้อนหลังไป 7 วัน
        $startDate = date('Y-m-d', strtotime('-7 days'));
    } elseif ($filter === 'month') {
        // ถ้าตัวกรองเป็นเดือน ให้คำนวณวันที่เริ่มต้นย้อนหลังไป 30 วัน
        $startDate = date('Y-m-d', strtotime('-30 days'));
    } elseif ($filter === 'year') {
        // ถ้าตัวกรองเป็นปี ให้คำนวณวันที่เริ่มต้นย้อนหลังไป 365 วัน
        $startDate = date('Y-m-d', strtotime('-365 days'));
    }

    // ดึงข้อมูลเมนูจาก meal_photo_history
    $sqlPhoto = "
    SELECT
        fpm.menu_id, fpm.menu_name, fpm.ingredient_list, DATE(mph.created_at) as date
    FROM
        meal_photo_history mph
    JOIN
        users u ON mph.user_id = u.user_id
    JOIN
        food_photo_menu fpm ON mph.menu_id = fpm.menu_id
    WHERE
        u.email = ? AND DATE(mph.created_at) BETWEEN ? AND ?
    ORDER BY
        DATE(mph.created_at)
    ";

    // ดึงข้อมูลเมนูจาก meal_history
    $sqlMeal = "
    SELECT
        mh.menu_id,
        fm.menu_name,
        GROUP_CONCAT(mni.ingredient_id ORDER BY mni.ingredient_id) AS ingredient_list_id,
        DATE(mh.meal_time) as date
    FROM
        meal_history mh
    JOIN
        users u ON mh.user_id = u.user_id
    JOIN
        food_menu fm ON mh.menu_id = fm.menu_id
    JOIN
        menu_nutritional_information mni ON mh.menu_id = mni.menu_id
    WHERE
        u.email = ? AND DATE(mh.meal_time) BETWEEN ? AND ?
    GROUP BY
        mh.menu_id,
        fm.menu_name,
        DATE(mh.meal_time)
    ORDER BY
        DATE(mh.meal_time)
    ";

    $menuDataByDay = []; // เก็บข้อมูลเมนูตามวัน
    $sugarOver1gCountByDay = []; // ตัวนับเมนูที่มีสารอาหาร > 1 กรัมแยกตามวัน
    $totalCount = 0; // ตัวแปรผลรวม

    // ฟังก์ชันเพื่อเช็คและคำนวณค่าสารอาหารรวม
    function calculateTotalNutrient($ingredients, $conn, $nutrient, $isMealHistory = false)
    {
        $ingredient_field = $isMealHistory ? 'ingredient_id' : 'ingredient_name';
        $ingredient_placeholders = implode(',', array_fill(0, count($ingredients), '?'));
        $sqlNutrient = "
        SELECT
            SUM($nutrient) AS total_nutrient
        FROM
            nutritional_information
        WHERE
            $ingredient_field IN ($ingredient_placeholders)
        ";

        if ($stmtNutrient = $conn->prepare($sqlNutrient)) {
            $stmtNutrient->bind_param(str_repeat('s', count($ingredients)), ...$ingredients);
            $stmtNutrient->execute();
            $resultNutrient = $stmtNutrient->get_result();

            if ($rowNutrient = $resultNutrient->fetch_assoc()) {
                return floatval($rowNutrient['total_nutrient']);
            }
        }

        return 0;
    }

    // เตรียมและประมวลผล SQL สำหรับ meal_photo_history
    if ($stmtPhoto = $conn->prepare($sqlPhoto)) {
        $stmtPhoto->bind_param("sss", $email, $startDate, $endDate);
        $stmtPhoto->execute();
        $resultPhoto = $stmtPhoto->get_result();

        if ($resultPhoto->num_rows > 0) {
            while ($row = $resultPhoto->fetch_assoc()) {
                $ingredientList = json_decode($row['ingredient_list'], true); // แปลงเป็น array
                $date = $row['date']; // วันที่แต่ละเมนูถูกบันทึก

                if (is_array($ingredientList)) {
                    // คำนวณค่าสารอาหารรวมจาก ingredient_name
                    $totalNutrient = calculateTotalNutrient($ingredientList, $conn, $nutrient);

                    // เพิ่มใน array ของข้อมูลเมนูแยกตามวัน
                    $menuDataByDay[$date][] = [
                        "menu_id" => $row['menu_id'],
                        "menu_name" => $row['menu_name'],
                        "total_nutrient" => $totalNutrient, // ค่าสารอาหารรวมของเมนู
                    ];

                    // เช็คค่าสารอาหาร > 1 กรัม และเพิ่มการนับถ้ามากกว่า 1 กรัม
                    if ($totalNutrient > 1) {
                        if (!isset($sugarOver1gCountByDay[$date])) {
                            $sugarOver1gCountByDay[$date] = 0;
                        }
                        $sugarOver1gCountByDay[$date]++;
                        $totalCount++; // เพิ่มตัวนับผลรวม
                    }
                }
            }
        }
    }

    // เตรียมและประมวลผล SQL สำหรับ meal_history
    if ($stmtMeal = $conn->prepare($sqlMeal)) {
        $stmtMeal->bind_param("sss", $email, $startDate, $endDate);
        $stmtMeal->execute();
        $resultMeal = $stmtMeal->get_result();

        if ($resultMeal->num_rows > 0) {
            while ($row = $resultMeal->fetch_assoc()) {
                $ingredientList = explode(',', $row['ingredient_list_id']); // แปลงเป็น array
                $date = $row['date']; // วันที่แต่ละเมนูถูกบันทึก

                // คำนวณค่าสารอาหารรวมจาก ingredient_id
                $totalNutrient = calculateTotalNutrient($ingredientList, $conn, $nutrient, true);

                // เพิ่มใน array ของข้อมูลเมนูแยกตามวัน
                $menuDataByDay[$date][] = [
                    "menu_id" => $row['menu_id'],
                    "menu_name" => $row['menu_name'],
                    "total_nutrient" => $totalNutrient, // ค่าสารอาหารรวมของเมนู
                ];

                // เช็คค่าสารอาหาร > 1 กรัม และเพิ่มการนับถ้ามากกว่า 1 กรัม
                if ($totalNutrient > 1) {
                    if (!isset($sugarOver1gCountByDay[$date])) {
                        $sugarOver1gCountByDay[$date] = 0;
                    }
                    $sugarOver1gCountByDay[$date]++;
                    $totalCount++; // เพิ่มตัวนับผลรวม
                }
            }
        }
    }

    // ส่งผลลัพธ์กลับเป็น JSON รวมกับการนับเมนูที่มีสารอาหาร > 1 กรัมแยกตามวัน และผลรวม
    echo json_encode([
        "status" => "success",
        "data" => $menuDataByDay, // ข้อมูลเมนูแยกตามวัน
        "count_nutrient_over_1g" => $sugarOver1gCountByDay, // จำนวนเมนูที่มีสารอาหาร > 1 กรัมแยกตามวัน
        "total_nutrient_over_1g" => $totalCount, // ผลรวมจำนวนเมนูที่มีสารอาหาร > 1 กรัม
    ]);
} else {
    echo json_encode(["status" => "error", "message" => "ไม่มีข้อมูล email"]);
}

// ปิดการเชื่อมต่อฐานข้อมูล
$conn->close();
