<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST, GET, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type");
header('Content-Type: application/json');

include "./conn.php";

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    // Check if the required fields are present
    if (isset($_POST['user_id'], $_POST['menu_name'], $_POST['ingredient_list'], $_POST['disease_list'], $_FILES['photo'])) {
        $user_id = intval($_POST['user_id']);
        $menu_name = $_POST['menu_name'];

        // Decode ingredient_list and disease_list from JSON to array
        $ingredient_list = json_decode($_POST['ingredient_list'], true);
        $disease_list = json_decode($_POST['disease_list'], true);

        // Handle the uploaded photo file
        $photo = $_FILES['photo'];
        $upload_dir = 'uploads/photos/';

        // Validate the uploaded file
        $allowed_extensions = ['jpg', 'jpeg', 'png', 'gif'];
        $photo_extension = pathinfo($photo['name'], PATHINFO_EXTENSION);

        if (!in_array(strtolower($photo_extension), $allowed_extensions)) {
            echo json_encode(['status' => 'error', 'message' => 'Invalid file type. Only JPG, PNG, and GIF are allowed.']);
            exit;
        }

        // Generate a unique name for the photo file
        $photo_name = 'photo_' . $user_id . '_' . time() . '.' . $photo_extension;
        $photo_path = $upload_dir . $photo_name;

        // Move uploaded file to the upload directory
        if (move_uploaded_file($photo['tmp_name'], $photo_path)) {
            // Convert ingredient_list and disease_list to JSON strings for storage
            $ingredient_list_json = json_encode($ingredient_list);
            $disease_list_json = json_encode($disease_list);

            // Prepare SQL query to insert data into food_photo_menu
            $sql = "INSERT INTO food_photo_menu (user_id, menu_name, image_url, ingredient_list, disease_list, created_at)
                    VALUES (?, ?, ?, ?, ?, NOW())";

            if ($stmt = $conn->prepare($sql)) {
                $stmt->bind_param('issss', $user_id, $menu_name, $photo_name, $ingredient_list_json, $disease_list_json);

                if ($stmt->execute()) {
                    // Get the last inserted menu_id
                    $menu_id = $stmt->insert_id;

                    // Return success response with menu_id
                    echo json_encode(['status' => 'success', 'menu_id' => $menu_id, 'message' => 'Meal history saved successfully.'], JSON_UNESCAPED_UNICODE);
                } else {
                    echo json_encode(['status' => 'error', 'message' => 'Failed to save meal history.'], JSON_UNESCAPED_UNICODE);
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
