<?php
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET');
header('Access-Control-Allow-Headers: Content-Type');

include "../conn.php"; // Include your database connection file

// SQL query to fetch distinct food menu items with their categories
$sql = "SELECT DISTINCT food_menu.menu_id, food_menu.menu_name, food_menu.image_url, food_menu.created_at,
               food_categories.category_name
        FROM food_menu
        LEFT JOIN food_categories ON food_menu.category_id = food_categories.id";

$result = $conn->query($sql);

$food_items = array();
if ($result->num_rows > 0) {
    while ($row = $result->fetch_assoc()) {
        $food_items[] = $row;
    }
}

// Return the JSON response
echo json_encode($food_items);

// Close the database connection
$conn->close();
