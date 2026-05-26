<?php
// includes/db_connect.php
// SQL Server connection using PDO

if (!function_exists('envValue')) {
    function envValue($key, $default = '') {
        $value = getenv($key);
        if ($value === false || $value === '') {
            return $default;
        }

        return $value;
    }
}

// Database configuration
define('DB_CONNECTION', envValue('DB_CONNECTION', 'odbc'));
define('DB_SERVER', envValue('DB_HOST', '(localdb)\\MSSQLLocalDB'));
define('DB_PORT', envValue('DB_PORT', ''));
define('DB_NAME', envValue('DB_NAME', 'PrototypeDO_DB'));
define('DB_USERNAME', envValue('DB_USERNAME', ''));
define('DB_PASSWORD', envValue('DB_PASSWORD', ''));
define('DB_ODBC_DRIVER', envValue('DB_ODBC_DRIVER', 'ODBC Driver 17 for SQL Server'));
define('DB_ENCRYPT', envValue('DB_ENCRYPT', 'true'));
define('DB_TRUST_SERVER_CERTIFICATE', envValue('DB_TRUST_SERVER_CERTIFICATE', 'true'));

// Global connection variable
$conn = null;

function buildConnectionString() {
    $server = DB_SERVER;
    if (DB_PORT !== '') {
        $server .= ',' . DB_PORT;
    }

    if (strtolower(DB_CONNECTION) === 'sqlsrv') {
        $parts = [
            'sqlsrv:Server=' . $server,
            'Database=' . DB_NAME,
        ];

        if (DB_USERNAME !== '' || DB_PASSWORD !== '') {
            $parts[] = 'UID=' . DB_USERNAME;
            $parts[] = 'PWD=' . DB_PASSWORD;
        } else {
            $parts[] = 'IntegratedSecurity=true';
        }

        if (DB_ENCRYPT !== '') {
            $parts[] = 'Encrypt=' . DB_ENCRYPT;
        }

        if (DB_TRUST_SERVER_CERTIFICATE !== '') {
            $parts[] = 'TrustServerCertificate=' . DB_TRUST_SERVER_CERTIFICATE;
        }

        return implode(';', $parts) . ';';
    }

    $parts = [
        'odbc:Driver={' . DB_ODBC_DRIVER . '}',
        'Server=' . $server,
        'Database=' . DB_NAME,
    ];

    if (DB_USERNAME !== '' || DB_PASSWORD !== '') {
        $parts[] = 'Uid=' . DB_USERNAME;
        $parts[] = 'Pwd=' . DB_PASSWORD;
    } else {
        $parts[] = 'Trusted_Connection=yes';
    }

    if (DB_ENCRYPT !== '') {
        $parts[] = 'Encrypt=' . DB_ENCRYPT;
    }

    if (DB_TRUST_SERVER_CERTIFICATE !== '') {
        $parts[] = 'TrustServerCertificate=' . DB_TRUST_SERVER_CERTIFICATE;
    }

    return implode(';', $parts) . ';';
}

function getDBConnection() {
    global $conn;
    
    // Return existing connection if already established
    if ($conn !== null) {
        return $conn;
    }
    
    try {
        // If using MySQL, build DSN and pass username/password explicitly
        if (in_array(strtolower(DB_CONNECTION), ['mysql', 'pdo_mysql', 'mysqli'])) {
            $host = DB_SERVER;
            $port = DB_PORT !== '' ? DB_PORT : null;
            $dsn = 'mysql:host=' . $host . ($port ? ';port=' . $port : '') . ';dbname=' . DB_NAME . ';charset=utf8mb4';

            $options = [
                PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
                PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
                PDO::ATTR_EMULATE_PREPARES => false,
            ];

            $username = DB_USERNAME !== '' ? DB_USERNAME : null;
            $password = DB_PASSWORD !== '' ? DB_PASSWORD : null;

            // Create PDO connection for MySQL
            $conn = new PDO($dsn, $username, $password, $options);

            // Ensure proper charset/collation
            try {
                $conn->exec("SET NAMES 'utf8mb4' COLLATE 'utf8mb4_unicode_ci'");
            } catch (PDOException $e) {
                // ignore charset setting failure
            }

            return $conn;
        }

        $connectionString = buildConnectionString();

        // Create PDO connection for ODBC/SQLSRV
        $conn = new PDO($connectionString);

        // Set error mode to exceptions
        $conn->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

        // Set default fetch mode to associative array
        $conn->setAttribute(PDO::ATTR_DEFAULT_FETCH_MODE, PDO::FETCH_ASSOC);

        return $conn;
        
    } catch(PDOException $e) {
        // Log error (in production, log to file instead of displaying)
        error_log(
            'Database Connection Error [' . DB_CONNECTION . '|' . DB_SERVER . '|' . DB_NAME . ']: ' .
            $e->getMessage()
        );
        die("Database connection failed. Please contact system administrator.");
    }
}

// Close database connection
function closeDBConnection() {
    global $conn;
    $conn = null;
}

// Helper function to execute queries safely
function executeQuery($sql, $params = []) {
    try {
        $conn = getDBConnection();
        $stmt = $conn->prepare($sql);
        
        // For SQL Server ODBC, let PDO handle parameter binding automatically
        // This avoids "Invalid character value for cast specification" errors
        $stmt->execute($params);
        return $stmt;
    } catch(PDOException $e) {
        error_log("Query Error: " . $e->getMessage());
        throw $e;
    }
}

// Helper function to get single row
function fetchOne($sql, $params = []) {
    $stmt = executeQuery($sql, $params);
    return $stmt->fetch();
}

// Helper function to get all rows
function fetchAll($sql, $params = []) {
    $stmt = executeQuery($sql, $params);
    return $stmt->fetchAll();
}

// Helper function to get single value
function fetchValue($sql, $params = []) {
    $stmt = executeQuery($sql, $params);
    $row = $stmt->fetch(PDO::FETCH_NUM);
    return $row ? $row[0] : null;
}

// Helper function for INSERT and get last inserted ID
function insertAndGetId($sql, $params = []) {
    $stmt = executeQuery($sql, $params);
    $conn = getDBConnection();
    return $conn->lastInsertId();
}
?>