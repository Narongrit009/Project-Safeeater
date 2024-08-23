<?php
include 'conn.php';

header('Content-Type: application/json');
header("Access-Control-Allow-Origin: *");

// Ensure the request method is POST
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    // Get user input
    $email = mysqli_real_escape_string($conn, $_POST['email']);

    // Use prepared statement to prevent SQL injection
    $stmt = mysqli_prepare($conn,
        "SELECT
    users.email,
    users.username,
    users.tel,
    health_conditions.condition_name,
    users.gender,
    users.age,
    users.height,
    users.weight
FROM
    users
LEFT JOIN
    health_conditions ON users.condition_id = health_conditions.condition_id
WHERE
    users.email = ?");

    mysqli_stmt_bind_param($stmt, "s", $email);
    mysqli_stmt_execute($stmt);
    $result = mysqli_stmt_get_result($stmt);

    // Check if the query was successful
    if ($result) {
        $output = array(); // Initialize an array to hold results
        while ($row = mysqli_fetch_assoc($result)) {
            $output[] = $row;
        }
        // Set response code based on whether results were found or not
        $response_code = (count($output) > 0) ? 200 : 404;
        http_response_code($response_code);
        echo json_encode($output);
    } else {
        // Send error response code
        http_response_code(500);
        echo json_encode(array("message" => "Internal Server Error"));
    }

    // Close prepared statement
    mysqli_stmt_close($stmt);
} else {
    // Invalid request method
    http_response_code(405); // Method Not Allowed
    echo json_encode(array("message" => "Invalid Request Method"));
}

// Close database connection
mysqli_close($conn);
