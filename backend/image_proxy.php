<?php
// Get the image URL from the query string
$imageUrl = isset($_GET['url']) ? $_GET['url'] : '';

if (!empty($imageUrl)) {
    // Check if the URL is valid
    if (filter_var($imageUrl, FILTER_VALIDATE_URL)) {
        // Get the content type
        $headers = get_headers($imageUrl, 1);
        $contentType = isset($headers['Content-Type']) ? $headers['Content-Type'] : 'image/jpeg';

        // Set the appropriate headers
        header('Content-Type: ' . $contentType);
        header('Access-Control-Allow-Origin: *');

        // Output the image
        echo file_get_contents($imageUrl);
    } else {
        echo 'Invalid URL';
    }
} else {
    echo 'No URL provided';
}
