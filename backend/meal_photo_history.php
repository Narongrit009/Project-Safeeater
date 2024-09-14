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
    if (isset($_POST['user_id'], $_POST['menu_name'], $_POST['is_edible'], $_FILES['photo'])) {
        $user_id = intval($_POST['user_id']);
        $menu_name = $_POST['menu_name'];
        $is_edible = $_POST['is_edible'];

        // Handle the uploaded photo file
        $photo = $_FILES['photo'];
        $upload_dir = 'uploads/photos/';

        // Generate a unique name for the photo file based on user_id and current timestamp
        $photo_extension = pathinfo($photo['name'], PATHINFO_EXTENSION); // Get the extension of the uploaded file
        $photo_name = 'photo_' . $user_id . '_' . time() . '.' . $photo_extension; // Generate unique file name
        $photo_path = $upload_dir . $photo_name;

        // Move uploaded file to the upload directory
        if (move_uploaded_file($photo['tmp_name'], $photo_path)) {
            // Prepare SQL query to insert data into meal_photo_history
            $sql = "INSERT INTO meal_photo_history (user_id, menu_name, is_edible, photo_url, created_at)
                    VALUES (?, ?, ?, ?, NOW())";

            if ($stmt = $conn->prepare($sql)) {
                // Save only the photo file name (not the full path)
                $stmt->bind_param('isss', $user_id, $menu_name, $is_edible, $photo_name);

                // Execute the query
                if ($stmt->execute()) {
                    echo json_encode(['status' => 'success', 'message' => 'Meal history saved successfully.']);
                } else {
                    echo json_encode(['status' => 'error', 'message' => 'Failed to save meal history.']);
                }

                $stmt->close();
            } else {
                echo json_encode(['status' => 'error', 'message' => 'Database error.']);
            }
        } else {
            echo json_encode(['status' => 'error', 'message' => 'Failed to upload photo.']);
        }
    } else {
        echo json_encode(['status' => 'error', 'message' => 'Invalid input data.']);
    }
} else {
    echo json_encode(['status' => 'error', 'message' => 'Invalid request method.']);
}

// Close the database connection
$conn->close();
