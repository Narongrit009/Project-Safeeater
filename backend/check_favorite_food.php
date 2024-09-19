<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST, GET, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type");
header('Content-Type: application/json');

include "./conn.php";

// Receive JSON input
$data = json_decode(file_get_contents('php://input'), true);

// Check if the required data is available
if (isset($data['email']) && isset($data['menu_id']) && isset($data['history_type'])) {
    $email = $data['email'];
    $menu_id = $data['menu_id'];
    $history_type = $data['history_type']; // This is the new field to indicate the table

    // Define the SQL statement depending on the history type (meal history or photo history)
    if ($history_type === 'meal') {
        // Check favorite from food_menu table
        $sql = "SELECT ff.is_favorite
                FROM favorite_food ff
                JOIN users u ON ff.user_id = u.user_id
                JOIN food_menu fm ON ff.food_id = fm.menu_id
                WHERE u.email = ? AND fm.menu_id = ?";
    } elseif ($history_type === 'photo') {
        // Check favorite from food_photo_menu table
        $sql = "SELECT ff.is_favorite
                FROM favorite_food ff
                JOIN users u ON ff.user_id = u.user_id
                JOIN food_photo_menu fpm ON ff.menu_id = fpm.menu_id
                WHERE u.email = ? AND fpm.menu_id = ?";
    } else {
        echo json_encode(['status' => 'error', 'message' => 'Invalid history type.']);
        exit;
    }

    // Prepare the statement
    if ($stmt = $conn->prepare($sql)) {
        // Bind parameters
        $stmt->bind_param("si", $email, $menu_id); // 'si' means string and integer

        // Execute the statement
        $stmt->execute();

        // Get the result
        $result = $stmt->get_result();

        // Check if a record exists
        if ($result->num_rows > 0) {
            $row = $result->fetch_assoc();
            // Output the is_favorite value
            echo json_encode([
                "status" => "success",
                "is_favorite" => $row['is_favorite'],
            ]);
        } else {
            // No favorite found
            echo json_encode([
                "status" => "not_found",
                "message" => "The menu is not marked as favorite by this user.",
            ]);
        }
        // Close the statement
        $stmt->close();
    } else {
        // Query preparation failed
        echo json_encode([
            "status" => "error",
            "message" => "Failed to prepare the SQL query.",
        ]);
    }
} else {
    // Missing required data
    echo json_encode([
        "status" => "error",
        "message" => "Missing email, menu_id, or history_type in request.",
    ]);
}

// Close the database connection
$conn->close();
