<?php
session_start();
define('INCLUDED_PAGE', true);
// Display all errors
error_reporting(E_ALL);
ini_set('display_errors', 1);
$page = (isset($_GET['page']) && $_GET['page'] != '') ? $_GET['page'] : '';
include '../classes/class.user.php';
$users = new User();
?>
<!DOCTYPE html>
<html>
<head>
    <title>Admin - User Management</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link rel="stylesheet" href="styles/stylesheet.css?<?php echo rand();?>">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css">
</head>
<body>
<div class="container mt-5">
    <h2>User Management Dashboard</h2>
    <a href="?">Home</a>
    <!-- Preloader -->
    <div class="preloader" id="preloader">
        <div class="dots">
            <div class="dot"></div>
            <div class="dot"></div>
            <div class="dot"></div>
        </div>
    </div>
    <!-- Page Container Start -->
    <?php
      switch($page){
        case 'users':
            require_once 'users.php';
            break;
        case 'functions':
              require_once 'functions.php';
              break;
        case 'permissions':
            require_once 'permissions.php';
            break;
        default:
            require_once 'default.php';
            break; 
    }
    ?>
    <!-- Page Container End -->
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
<script>
     // Show preloader when a menu item is clicked
     function showPreloader(event, url) {
            event.preventDefault(); // Prevent page navigation

            // Show the preloader
            document.getElementById('preloader').style.display = 'flex';

            // Simulate loading (you can replace this with actual loading tasks or AJAX calls)
            setTimeout(function() {
                // Navigate to the desired page after the preloader disappears
                window.location.href = url;
            }, 2000); // Simulated loading time (2 seconds for demonstration)
        }
    </script>
</body>
</html>