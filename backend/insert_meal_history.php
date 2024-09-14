<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST, GET, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type");
header('Content-Type: application/json');

// Include the database connection
include "./conn.php";

// Receive JSON input
$data = json_decode(file_get_contents('php://input'), true);

if (isset($data['user_id']) && isset($data['menu_id']) && isset($data['is_edible'])) {
    $user_id = $data['user_id'];
    $menu_id = $data['menu_id'];
    $is_edible = $data['is_edible'];

    // Validate that 'is_edible' is either 'true' or 'false'
    if ($is_edible !== 'true' && $is_edible !== 'false') {
        echo json_encode(["status" => "error", "message" => "Invalid is_edible value"]);
        exit();
    }

    // Prepare the SQL statement
    $insert_query = $conn->prepare("
        INSERT INTO meal_history (user_id, menu_id, is_edible, meal_time)
        VALUES (?, ?, ?, NOW())
    ");
    $insert_query->bind_param("iis", $user_id, $menu_id, $is_edible);

    // Execute the query
    if ($insert_query->execute()) {
        echo json_encode(["status" => "success", "message" => "Meal history inserted successfully"]);
    } else {
        echo json_encode(["status" => "error", "message" => "Failed to insert meal history"]);
    }

    // Close the query
    $insert_query->close();
} else {
    echo json_encode(["status" => "error", "message" => "Invalid input"]);
}

// Close the database connection
$conn->close();
