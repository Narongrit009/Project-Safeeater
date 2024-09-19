<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST, GET, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type");
header('Content-Type: application/json');

// Include the database connection
include "./conn.php";

// Receive JSON input
$data = json_decode(file_get_contents('php://input'), true);

// Check if the required data is available
if (isset($data['email']) && isset($data['menu_id']) && isset($data['is_favorite']) && isset($data['history_type'])) {
    $email = $data['email'];
    $menu_id = $data['menu_id'];
    $is_favorite = $data['is_favorite'] === 'true' ? 1 : 0; // Convert to 1 (true) or 0 (false)
    $history_type = $data['history_type']; // Determine if it's 'meal' or 'photo'

    // Get user_id from the email
    $getUserSql = "SELECT user_id FROM users WHERE email = ?";
    $stmt = $conn->prepare($getUserSql);
    $stmt->bind_param("s", $email);
    $stmt->execute();
    $userResult = $stmt->get_result();

    if ($userResult->num_rows > 0) {
        $userRow = $userResult->fetch_assoc();
        $user_id = $userRow['user_id'];

        // Depending on history_type, select the correct table
        if ($history_type === 'meal') {
            // Check if the favorite already exists in the meal table
            $checkFavoriteSql = "SELECT * FROM favorite_food WHERE user_id = ? AND food_id = ?";
        } elseif ($history_type === 'photo') {
            // Check if the favorite already exists in the photo table
            $checkFavoriteSql = "SELECT * FROM favorite_food WHERE user_id = ? AND menu_id = ?";
        } else {
            echo json_encode(["status" => "error", "message" => "Invalid history type"]);
            exit;
        }

        $stmt = $conn->prepare($checkFavoriteSql);
        $stmt->bind_param("ii", $user_id, $menu_id);
        $stmt->execute();
        $favoriteResult = $stmt->get_result();

        if ($favoriteResult->num_rows > 0) {
            // If the record exists, update the is_favorite field
            if ($history_type === 'meal') {
                $updateSql = "UPDATE favorite_food SET is_favorite = ? WHERE user_id = ? AND food_id = ?";
            } elseif ($history_type === 'photo') {
                $updateSql = "UPDATE favorite_food SET is_favorite = ? WHERE user_id = ? AND menu_id = ?";
            }

            $stmt = $conn->prepare($updateSql);
            $stmt->bind_param("iii", $is_favorite, $user_id, $menu_id);
            if ($stmt->execute()) {
                echo json_encode(["status" => "success", "message" => "Favorite status updated"]);
            } else {
                echo json_encode(["status" => "error", "message" => "Failed to update favorite status"]);
            }
        } else {
            // If the record doesn't exist, insert a new favorite record
            if ($history_type === 'meal') {
                $insertSql = "INSERT INTO favorite_food (user_id, food_id, is_favorite) VALUES (?, ?, ?)";
            } elseif ($history_type === 'photo') {
                $insertSql = "INSERT INTO favorite_food (user_id, menu_id, is_favorite) VALUES (?, ?, ?)";
            }

            $stmt = $conn->prepare($insertSql);
            $stmt->bind_param("iii", $user_id, $menu_id, $is_favorite);
            if ($stmt->execute()) {
                echo json_encode(["status" => "success", "message" => "Favorite added"]);
            } else {
                echo json_encode(["status" => "error", "message" => "Failed to add favorite"]);
            }
        }
    } else {
        // No user found for the provided email
        echo json_encode(["status" => "error", "message" => "User not found"]);
    }

    // Close the statement
    $stmt->close();
} else {
    // Missing required data
    echo json_encode(["status" => "error", "message" => "Missing email, menu_id, is_favorite, or history_type"]);
}

// Close the database connection
$conn->close();
