<?php
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Access-Control-Allow-Headers, Authorization, X-Requested-With');

include "../conn.php"; // Include your database connection file

// Get the request method
$requestMethod = $_SERVER['REQUEST_METHOD'];

// Handle the request based on the request method
switch ($requestMethod) {
    case 'GET':
        // Fetch all categories
        $sql = "SELECT id, category_name, description FROM food_categories";
        $result = $conn->query($sql);

        $categories = array();
        if ($result && $result->num_rows > 0) {
            while ($row = $result->fetch_assoc()) {
                $categories[] = $row;
            }
            echo json_encode($categories);
        } else {
            echo json_encode(['status' => 'error', 'message' => 'No categories found']);
        }
        break;

    case 'POST':
        // Add a new category
        $data = json_decode(file_get_contents("php://input"), true);
        $category_name = trim($data['category_name']);
        $description = trim($data['description']);

        if (!empty($category_name)) {
            $sql = "INSERT INTO food_categories (category_name, description) VALUES (?, ?)";
            $stmt = $conn->prepare($sql);
            $stmt->bind_param('ss', $category_name, $description);
            if ($stmt->execute()) {
                echo json_encode(['status' => 'success', 'message' => 'Category added successfully']);
            } else {
                echo json_encode(['status' => 'error', 'message' => 'Failed to add category']);
            }
            $stmt->close();
        } else {
            echo json_encode(['status' => 'error', 'message' => 'Invalid input: Category name is required']);
        }
        break;

    case 'PUT':
        // Update an existing category
        $data = json_decode(file_get_contents("php://input"), true);
        $id = $data['id'];
        $category_name = trim($data['category_name']);
        $description = trim($data['description']);

        if (!empty($id) && !empty($category_name)) {
            $sql = "UPDATE food_categories SET category_name = ?, description = ? WHERE id = ?";
            $stmt = $conn->prepare($sql);
            $stmt->bind_param('ssi', $category_name, $description, $id);
            if ($stmt->execute()) {
                echo json_encode(['status' => 'success', 'message' => 'Category updated successfully']);
            } else {
                echo json_encode(['status' => 'error', 'message' => 'Failed to update category']);
            }
            $stmt->close();
        } else {
            echo json_encode(['status' => 'error', 'message' => 'Invalid input: ID and Category name are required']);
        }
        break;

    case 'DELETE':
        // Delete a category
        if (isset($_GET['id'])) {
            $id = $_GET['id'];
            $sql = "DELETE FROM food_categories WHERE id = ?";
            $stmt = $conn->prepare($sql);
            $stmt->bind_param('i', $id);
            if ($stmt->execute()) {
                echo json_encode(['status' => 'success', 'message' => 'Category deleted successfully']);
            } else {
                echo json_encode(['status' => 'error', 'message' => 'Failed to delete category']);
            }
            $stmt->close();
        } else {
            echo json_encode(['status' => 'error', 'message' => 'Invalid input']);
        }
        break;

    case 'OPTIONS':
        // Handle preflight requests for CORS
        http_response_code(200);
        break;

    default:
        echo json_encode(['status' => 'error', 'message' => 'Invalid request method']);
        break;
}

// Close the database connection
$conn->close();
