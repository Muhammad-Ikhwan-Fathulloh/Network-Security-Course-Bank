<?php
echo "<h1>ADMIN PANEL - VULNERABLE</h1>";
echo "<h2>System Information</h2>";
echo "<pre>";
echo "Server Software: " . $_SERVER['SERVER_SOFTWARE'] . "\n";
echo "Document Root: " . $_SERVER['DOCUMENT_ROOT'] . "\n";
echo "PHP Version: " . phpversion() . "\n";
echo "</pre>";

echo "<h2>Database Configuration</h2>";
echo "<pre>";
$db_config = file_get_contents('/var/www/html/config/database.php');
echo $db_config;
echo "</pre>";

echo "<h2>PHP Info</h2>";
phpinfo();
?>