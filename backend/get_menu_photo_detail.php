<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST, GET, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type");
header('Content-Type: application/json');

include "./conn.php";

// รับข้อมูล JSON จากการร้องขอ
$data = json_decode(file_get_contents('php://input'), true);

if (isset($data['menu_id']) && !empty($data['menu_id'])) {
    $menu_id = $data['menu_id'];

    // Query to get menu details from food_photo_menu
    $menu_query = $conn->prepare("
        SELECT menu_name, image_url, ingredient_list, disease_list, created_at
        FROM food_photo_menu
        WHERE menu_id = ?
    ");
    $menu_query->bind_param("i", $menu_id);
    $menu_query->execute();
    $menu_result = $menu_query->get_result();

    if ($menu_result->num_rows > 0) {
        $menu_data = $menu_result->fetch_assoc();

        // Extract and split the ingredient list
        $ingredient_list = json_decode($menu_data['ingredient_list'], true);

        // Sanitize and prepare ingredients for SQL comparison
        $ingredient_list = array_map(function ($ingredient) use ($conn) {
            return $conn->real_escape_string(trim($ingredient));
        }, $ingredient_list);

        // Query for matching ingredients and their images and IDs from nutritional_information
        $ingredient_placeholders = implode(',', array_fill(0, count($ingredient_list), '?'));
        $ingredient_query = $conn->prepare("
            SELECT ingredient_id, ingredient_name, image_url
            FROM nutritional_information
            WHERE ingredient_name IN ($ingredient_placeholders)
        ");
        $ingredient_query->bind_param(str_repeat('s', count($ingredient_list)), ...$ingredient_list);
        $ingredient_query->execute();
        $ingredient_result = $ingredient_query->get_result();

        $matched_ingredients = [];
        $ingredient_ids = [];
        $ingredient_images = [];

        while ($row = $ingredient_result->fetch_assoc()) {
            $matched_ingredients[] = $row['ingredient_name'];
            $ingredient_ids[] = $row['ingredient_id'];
            $ingredient_images[] = $row['image_url'];
        }

        // Prepare the response data with dynamic host for image URL
        $host = $_SERVER['HTTP_HOST'];
        $response = [
            "status" => "success",
            "data" => [
                "menu_name" => $menu_data['menu_name'],
                // Adjusted only the main image_url with $host
                "image_url" => "http://" . $host . "/safeeater/uploads/photos/" . $menu_data['image_url'],

                // Leave ingredients_image without altering it with $host
                "ingredients" => implode(', ', $matched_ingredients),
                "ingredients_id" => implode(', ', $ingredient_ids),
                "ingredients_image" => implode(', ', $ingredient_images), // No change here

                "related_conditions" => !empty($menu_data['disease_list'])
                ? implode(', ', json_decode($menu_data['disease_list'], true))
                : "ไม่มีโรคที่เสี่ยง",
                "created_at" => $menu_data['created_at'], // ดึงค่า created_at ที่ถูกต้อง
            ],
        ];

        echo json_encode($response);

    } else {
        echo json_encode(["status" => "error", "message" => "Menu not found"]);
    }

    $menu_query->close();
} else {
    echo json_encode(["status" => "error", "message" => "Invalid input"]);
}

$conn->close();
