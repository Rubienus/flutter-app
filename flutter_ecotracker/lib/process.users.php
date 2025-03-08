<?php
include '../classes/class.user.php';

// Check if the form is submitted
if ($_SERVER['REQUEST_METHOD'] == 'POST') {
    // Retrieve form data
    $first_name = $_POST['first_name'];
    $last_name = $_POST['last_name'];
    $password = $_POST['password'];  // Ensure you hash the password in production
    $email = $_POST['email'];
    $role_id = $_POST['role_id'];
    $status = $_POST['status'];

    // Create an instance of the User class
    $user = new User();

    // Call the create_user method to add the user
    $response = $user->create_user($first_name, $last_name, $password, $email, $role_id, $status);

    // Return JSON response
    echo json_encode($response);
}
?>