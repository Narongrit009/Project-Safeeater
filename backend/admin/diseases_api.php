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
        // Fetch all diseases
        $sql = "SELECT condition_id, condition_name, condition_description FROM health_conditions";
        $result = $conn->query($sql);

        $diseases = array();
        if ($result && $result->num_rows > 0) {
            while ($row = $result->fetch_assoc()) {
                $diseases[] = $row;
            }
            echo json_encode($diseases);
        } else {
            echo json_encode(['status' => 'error', 'message' => 'No diseases found']);
        }
        break;

    case 'POST':
        // Add a new disease
        $data = json_decode(file_get_contents("php://input"), true);
        $name = trim($data['condition_name']);
        $description = trim($data['condition_description']);

        // Debugging: Log incoming data
        error_log("Received POST data: " . print_r($data, true));

        if (!empty($name)) {
            $sql = "INSERT INTO health_conditions (condition_name, condition_description) VALUES (?, ?)";
            $stmt = $conn->prepare($sql);
            $stmt->bind_param('ss', $name, $description);
            if ($stmt->execute()) {
                echo json_encode(['status' => 'success', 'message' => 'Disease added successfully']);
            } else {
                // Debugging: Log database error
                error_log("Database Error: " . $stmt->error);
                echo json_encode(['status' => 'error', 'message' => 'Failed to add disease']);
            }
            $stmt->close();
        } else {
            echo json_encode(['status' => 'error', 'message' => 'Invalid input: Disease name is required']);
        }
        break;

    case 'PUT':
        // Update an existing disease
        $data = json_decode(file_get_contents("php://input"), true);
        $id = isset($data['condition_id']) ? $data['condition_id'] : null;
        $name = isset($data['condition_name']) ? trim($data['condition_name']) : null;
        $description = isset($data['condition_description']) ? trim($data['condition_description']) : null;

        // Log the received data
        error_log("Received PUT data: " . print_r($data, true));

        if (!empty($id) && !empty($name)) {
            $sql = "UPDATE health_conditions SET condition_name = ?, condition_description = ? WHERE condition_id = ?";
            $stmt = $conn->prepare($sql);

            if (!$stmt) {
                // Log preparation errors
                error_log("SQL Prepare Error: " . $conn->error);
                echo json_encode(['status' => 'error', 'message' => 'Database prepare error']);
                break;
            }

            $stmt->bind_param('ssi', $name, $description, $id);

            if ($stmt->execute()) {
                // Log success
                error_log("Disease updated successfully: ID = $id, Name = $name, Description = $description");
                echo json_encode(['status' => 'success', 'message' => 'Disease updated successfully']);
            } else {
                // Log execution errors
                error_log("Database Execute Error: " . $stmt->error);
                echo json_encode(['status' => 'error', 'message' => 'Failed to update disease']);
            }
            $stmt->close();
        } else {
            error_log("Invalid input: ID and Disease name are required");
            echo json_encode(['status' => 'error', 'message' => 'Invalid input: ID and Disease name are required']);
        }
        break;

    case 'DELETE':
        // Delete a disease
        if (isset($_GET['id'])) {
            $id = $_GET['id'];
            $sql = "DELETE FROM health_conditions WHERE condition_id = ?";
            $stmt = $conn->prepare($sql);
            $stmt->bind_param('i', $id);
            if ($stmt->execute()) {
                echo json_encode(['status' => 'success', 'message' => 'Disease deleted successfully']);
            } else {
                echo json_encode(['status' => 'error', 'message' => 'Failed to delete disease']);
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
