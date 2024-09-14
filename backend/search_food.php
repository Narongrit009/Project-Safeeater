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

header("Content-Type: application/json");
include "./conn.php"; // Ensure the database connection file path is correct

// Get the search query from the POST request
$data = json_decode(file_get_contents('php://input'), true);

if (isset($data['query']) && !empty($data['query'])) {
    $query = "%" . $data['query'] . "%"; // Prepare the query for the LIKE statement

    // Modify the SQL query to search both menu name and category name
    $stmt = $conn->prepare("
        SELECT food_menu.menu_id, food_menu.menu_name, food_menu.image_url, food_menu.created_at,
               food_categories.category_name
        FROM food_menu
        LEFT JOIN food_categories
        ON food_menu.category_id = food_categories.id
        WHERE food_menu.menu_name LIKE ? OR food_categories.category_name LIKE ?
    ");
    $stmt->bind_param("ss", $query, $query);
    $stmt->execute();
    $result = $stmt->get_result();

    // Fetch the results and convert them to an array
    $foods = array();
    while ($row = $result->fetch_assoc()) {
        $foods[] = $row;
    }

    if (count($foods) > 0) {
        echo json_encode(["status" => "success", "data" => $foods]);
    } else {
        echo json_encode(["status" => "error", "message" => "No results found"]);
    }

    $stmt->close();
} else {
    echo json_encode(["status" => "error", "message" => "Invalid input"]);
}

$conn->close();
