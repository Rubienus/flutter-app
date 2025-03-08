<?php
function fetch_from_api($api_url, $postData) {
    // Prepare POST data
    $options = [
        'http' => [
            'method' => 'POST',
            'header' => "Content-Type: application/x-www-form-urlencoded\r\n",
            'content' => http_build_query($postData)
        ]
    ];

    // Create context
    $context = stream_context_create($options);

    // Fetch data from the API
    $response = file_get_contents($api_url, false, $context);

    // Handle the response
    if ($response === FALSE) {
        return [];
    }

    return json_decode($response, true);
}

function push_to_api($api_url, $postData) {
    
    // Prepare POST data
    $options = [
        'http' => [
            'method' => 'POST',
            'header' => "Content-Type: application/x-www-form-urlencoded\r\n",
            'content' => http_build_query($postData)
        ]
    ];

    // Create context
    $context = stream_context_create($options);

    // Fetch data from the API
    $response = file_get_contents($api_url, false, $context);

    // Handle the response
    if ($response === FALSE) {
        return [];
    }

    return json_decode($response, true);
}
?>
