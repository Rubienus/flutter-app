<?php
// no need to define 2 connections if using only 1 db
$host = 'url';
$db1   = 'database 1';
$user = 'user for both if applicable';
$pass = 'password';
$charset = 'utf8mb4';

$dsn1 = "mysql:host=$host;dbname=$db1;charset=$charset";
$dsn2 = "mysql:host=$host;dbname=$db2;charset=$charset";
$options = [
    PDO::ATTR_ERRMODE            => PDO::ERRMODE_EXCEPTION,
    PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
    PDO::ATTR_EMULATE_PREPARES   => false,
];

try {
    $stmt1 = new PDO($dsn1, $user, $pass, $options);
    $stmt1->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    // Second database connection
    $stmt2 = new PDO($dsn2, $user, $pass, $options);
    $stmt2->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
} catch (\PDOException $e) {
    throw new \PDOException($e->getMessage(), (int)$e->getCode());
}