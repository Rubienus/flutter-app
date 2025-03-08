<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST, GET, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Authorization");

session_start();
header('Content-Type: application/json'); // Set header for JSON response

require_once '../config/config-api.php'; // Include your database connection

// Extract API key from headers
$api_key = $_POST['api_key'] ?? null;
$load = $_POST['load'] ?? null;

if (!$api_key) {
    echo json_encode(['message' => 'API key missing']);
    exit();
}

// Validate the API key and get the user ID
try {
    $query1 = $stmt1->prepare("SELECT id FROM users WHERE api_key = ?");
    $query1->execute([$api_key]);
    $api_key_record = $query1->fetch();

    if (!$api_key_record) {
        echo json_encode(['message' => 'Invalid API key']);
        exit();
    }

    // Check what to load
    switch($load){
        case 'listing': 
            user_listing($stmt2);
            break;

                case 'create': 
                user_create($stmt2);
                break;

                    case 'roles': 
                        role_listing($stmt2);
                        break;
                    
                        case 'permissions': 
                            permission_listing($stmt2);
                            break;

                            case 'menu': 
                                menu_listing($stmt2);
                                break;
       
            default:
            echo json_encode(['message' => 'Invalid load parameter']);
            break;
    }

} catch (Exception $e) {
    echo json_encode(['message' => 'Server error', 'error' => $e->getMessage()]);
    exit();
}

// Function to list users
function user_listing($stmt2) {
    try {
        $query2 = $stmt2->query("SELECT user_id, user_first_name, user_last_name, user_email, role_id, user_status FROM tbl_users");
        $users = $query2->fetchAll(PDO::FETCH_ASSOC);

        // Output the result in JSON format
        echo json_encode([
            'message' => 'User list retrieved successfully',
            'users' => $users
        ]);
    } catch (Exception $e) {
        echo json_encode(['message' => 'Error retrieving users', 'error' => $e->getMessage()]);
    }
}

// Function to create users
function user_create($stmt2) {
    // Get the form inputs
    $first_name = ucwords($_POST['first_name'] ?? ''); // Get the first name
    $last_name = ucwords($_POST['last_name'] ?? ''); // Get the last name
    $password = $_POST['password'] ?? ''; // Get the password
    $email = $_POST['email'] ?? ''; // Get the email
    $role_id = $_POST['role_id'] ?? ''; // Get the role
    $status = $_POST['status'] ?? ''; // Get the status

    // Validate input
    if (empty($first_name) || empty($last_name) || empty($email) || empty($password) || empty($role_id) || empty($status)) {
        echo json_encode(['success' => false, 'message' => 'All fields are required.']);
        exit();
    }

    $query = $stmt2->prepare("SELECT user_id FROM tbl_users WHERE user_email = ?");
    $query->execute([$email]);
    $result = $query->fetch();

    if ($result > 0 ) {
        echo json_encode(['message' => 'This E-mail is already in use.']);
        exit();
    }

    // Hash the password
    $password = password_hash($password, PASSWORD_DEFAULT);
    
    try {
        // Prepare the INSERT statement
        $query2 = "INSERT INTO tbl_users (user_first_name, user_last_name, user_password, user_email, role_id, user_status)
                   VALUES (:first_name, :last_name, :password, :email, :role_id, :status)";
        
        // Prepare the SQL statement
        $stmtx = $stmt2->prepare($query2);
        
        // Bind the parameters to the SQL query
        $stmtx->bindParam(':first_name', $first_name);
        $stmtx->bindParam(':last_name', $last_name);
        $stmtx->bindParam(':password', $password);
        $stmtx->bindParam(':email', $email);
        $stmtx->bindParam(':role_id', $role_id);
        $stmtx->bindParam(':status', $status);

        // Execute the statement
        $stmtx->execute();

        // Return a success message
        echo json_encode([
            'message' => 'User created successfully'
        ]);
    } catch (Exception $e) {
        echo json_encode(['message' => 'Error creating user', 'error' => $e->getMessage()]);
    }
}

// Function to validate a users
function user_validate($stmt2) {
    // Get the form inputs
    $password = $_POST['password'] ?? ''; // Get the password
    $email = $_POST['email'] ?? ''; // Get the email
    $status = $_POST['status'] ?? ''; // Get the status

    // Validate input
    if (empty($email) || empty($password) || empty($status)) {
        echo json_encode(['success' => false, 'message' => 'All fields are required.']);
        exit();
    }

    /*if (password_verify($password, $hashed_password_from_db)) {
        echo 'Password is valid!';
    }*/

    // Hash the password
    $password = password_hash($password, PASSWORD_DEFAULT);
    
    try {
        // Prepare the INSERT statement
        $query2 = "INSERT INTO tbl_users (tbl_first_name, tbl_last_name, tbl_password, tbl_email, tbl_role_id, tbl_status)
                   VALUES (:first_name, :last_name, :password, :email, :role_id, :status)";
        
        // Prepare the SQL statement
        $stmtx = $stmt2->prepare($query2);
        
        // Bind the parameters to the SQL query
        $stmtx->bindParam(':first_name', $first_name);
        $stmtx->bindParam(':last_name', $last_name);
        $stmtx->bindParam(':password', $password);
        $stmtx->bindParam(':email', $email);
        $stmtx->bindParam(':role_id', $role_id);
        $stmtx->bindParam(':status', $status);

        // Execute the statement
        $stmtx->execute();

        // Return a success message
        echo json_encode([
            'message' => 'User created successfully'
        ]);
    } catch (Exception $e) {
        echo json_encode(['message' => 'Error creating user', 'error' => $e->getMessage()]);
    }
}

// Function to list roles
function role_listing($stmt2) {
    try {
        $query2 = $stmt2->query("SELECT role_id, role_name FROM tbl_roles");
        $roles = $query2->fetchAll(PDO::FETCH_ASSOC);

        // Output the result in JSON format
        echo json_encode([
            'message' => 'Role list retrieved successfully',
            'roles' => $roles
        ]);
    } catch (Exception $e) {
        echo json_encode(['message' => 'Error retrieving roles', 'error' => $e->getMessage()]);
    }
}

// Function to list roles
function permission_listing($stmt2) {
    try {
        $query2 = $stmt2->query("SELECT * FROM tbl_permissions");
        $permissions = $query2->fetchAll(PDO::FETCH_ASSOC);

        // Output the result in JSON format
        echo json_encode([
            'message' => 'Permission list retrieved successfully',
            'permissions' => $permissions
        ]);
    } catch (Exception $e) {
        echo json_encode(['message' => 'Error retrieving permissions', 'error' => $e->getMessage()]);
    }
}

function menu_listing($stmt2) {
    try {
        $query2 = $stmt2->query("SELECT * FROM tbl_menu");
        $permissions = $query2->fetchAll(PDO::FETCH_ASSOC);

        // Output the result in JSON format
        echo json_encode([
            'message' => 'Menu list retrieved successfully',
            'permissions' => $permissions
        ]);
    } catch (Exception $e) {
        echo json_encode(['message' => 'Error retrieving menu', 'error' => $e->getMessage()]);
    }
}