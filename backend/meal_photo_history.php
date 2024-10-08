<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST, GET, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type");
header('Content-Type: application/json');

include "./conn.php";

// Set headers to handle JSON data
header('Content-Type: application/json');

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    // Check if the required fields are present
    if (isset($_POST['user_id'], $_POST['menu_id'], $_POST['is_edible'])) {
        $user_id = intval($_POST['user_id']);
        $menu_id = intval($_POST['menu_id']);
        $is_edible = $_POST['is_edible'];

        // Prepare SQL query to insert data into meal_photo_history
        $sql = "INSERT INTO meal_photo_history (user_id, menu_id, is_edible, created_at)
                VALUES (?, ?, ?, NOW())";

        if ($stmt = $conn->prepare($sql)) {
            $stmt->bind_param('iis', $user_id, $menu_id, $is_edible);

            if ($stmt->execute()) {
                echo json_encode(['status' => 'success', 'message' => 'Meal photo history saved successfully.'], JSON_UNESCAPED_UNICODE);
            } else {
                echo json_encode(['status' => 'error', 'message' => 'Failed to save meal photo history.'], JSON_UNESCAPED_UNICODE);
            }

            $stmt->close();
        } else {
            echo json_encode(['status' => 'error', 'message' => 'Database error.']);
        }
    } else {
        echo json_encode(['status' => 'error', 'message' => 'Invalid input data.']);
    }
} else {
    echo json_encode(['status' => 'error', 'message' => 'Invalid request method.']);
}

// Close the database connection
$conn->close();
