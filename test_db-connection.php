<?php
require_once __DIR__ . '/includes/db_connect.php';

echo "<h1>Testing SQL Server Connection</h1>";

try {
    // Test 1: Check if PDO extension exists
    if (extension_loaded('pdo')) {
        echo "<p style='color: green;'>✅ PDO extension is loaded</p>";
    } else {
        echo "<p style='color: red;'>❌ PDO extension is NOT loaded</p>";
    }
    
    // Test 2: Check available PDO drivers
    $drivers = PDO::getAvailableDrivers();
    echo "<p><strong>Available PDO Drivers:</strong> " . implode(', ', $drivers) . "</p>";
    
    if (in_array('odbc', $drivers)) {
        echo "<p style='color: green;'>✅ ODBC driver is available</p>";
    } else {
        echo "<p style='color: red;'>❌ ODBC driver is NOT available</p>";
    }
    
    // Test 3: Try connection using the same helper the app uses
    echo "<hr><h2>Attempting Connection...</h2>";
    echo "<p><strong>Connection mode:</strong> " . htmlspecialchars(DB_CONNECTION) . "</p>";
    echo "<p><strong>Server:</strong> " . htmlspecialchars(DB_SERVER) . "</p>";
    echo "<p><strong>Database:</strong> " . htmlspecialchars(DB_NAME) . "</p>";
    echo "<p><strong>ODBC Driver:</strong> " . htmlspecialchars(DB_ODBC_DRIVER) . "</p>";

    $conn = getDBConnection();
    echo "<p style='color: green; font-size: 20px;'>✅ CONNECTION SUCCESSFUL!</p>";

    // Test query
    $stmt = $conn->query("SELECT @@VERSION as version");
    $row = $stmt->fetch(PDO::FETCH_ASSOC);
    echo "<p><strong>SQL Server Version:</strong> " . htmlspecialchars($row['version']) . "</p>";
    
} catch (Exception $e) {
    echo "<p style='color: red;'>❌ Fatal Error: " . $e->getMessage() . "</p>";
}
?>