<?php
// Enable error reporting
error_reporting(E_ALL);
ini_set('display_errors', 1);

header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST, GET, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Authorization");
header("Content-Type: application/json");

// Handle preflight OPTIONS request
if ($_SERVER['REQUEST_METHOD'] == 'OPTIONS') {
    http_response_code(200);
    exit();
}

include "./conn.php"; // Include the database connection file

// SQL query to fetch the first 10 menu items, ordered by creation date
$sql = "SELECT DISTINCT food_menu.menu_id, food_menu.menu_name, food_menu.image_url, food_menu.created_at,
                food_categories.category_name
FROM food_menu
LEFT JOIN food_categories
ON food_menu.category_id = food_categories.id
GROUP BY food_categories.category_name
ORDER BY food_menu.created_at DESC
LIMIT 6";

// Execute the query
$result = $conn->query($sql);

// Prepare the result to be returned as JSON
$foods = array();

if ($result->num_rows > 0) {
    while ($row = $result->fetch_assoc()) {
        // Ensure menu_id is cast as an integer
        $row['menu_id'] = (int) $row['menu_id'];
        $foods[] = $row;
    }

    // Return success response with food data
    echo json_encode([
        "status" => "success",
        "data" => $foods,
    ]);
} else {
    // Return error response if no data found
    echo json_encode([
        "status" => "error",
        "message" => "No menu items found",
    ]);
}

// Close the connection
$conn->close();
