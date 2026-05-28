<?php
header('Content-Type: application/json');

$users = [
    ['id' => 1, 'name' => 'Admin User', 'role' => 'superadmin', 'email' => 'admin@example.com'],
    ['id' => 2, 'name' => 'Regular User', 'role' => 'user', 'email' => 'user@example.com']
];

$config = [
    'database' => [
        'host' => 'localhost',
        'username' => 'root',
        'password' => 'SuperSecret123!',
        'dbname' => 'production_db'
    ],
    'api_keys' => [
        'stripe' => 'sk_live_abc123def456',
        'aws' => 'AKIAIOSFODNN7EXAMPLE'
    ],
    'debug_mode' => true
];

$method = $_SERVER['REQUEST_METHOD'];
$request_uri = $_SERVER['REQUEST_URI'];

if (strpos($request_uri, '/users') !== false) {
    if ($method === 'GET') {
        echo json_encode($users);
    } else {
        http_response_code(405);
        echo json_encode(['error' => 'Method not allowed']);
    }
} 
elseif (strpos($request_uri, '/config') !== false) {
    if ($method === 'GET') {
        echo json_encode($config);
    } else {
        http_response_code(405);
        echo json_encode(['error' => 'Method not allowed']);
    }
}
elseif (strpos($request_uri, '/health') !== false) {
    echo json_encode(['status' => 'ok', 'timestamp' => date('Y-m-d H:i:s')]);
}
else {
    http_response_code(404);
    echo json_encode(['error' => 'Endpoint not found']);
}
?>