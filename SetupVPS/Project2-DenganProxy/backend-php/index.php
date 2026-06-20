<?php
error_reporting(E_ALL);
ini_set('display_errors', 1);

header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Authorization');

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit();
}

$host = getenv('DB_HOST') ?: 'localhost';
$dbname = getenv('DB_NAME') ?: 'userdb';
$dbuser = getenv('DB_USER') ?: 'user';
$dbpass = getenv('DB_PASS') ?: 'password';

function getDBConnection($host, $dbname, $dbuser, $dbpass) {
    try {
        $pdo = new PDO("mysql:host=$host;dbname=$dbname;charset=utf8mb4", $dbuser, $dbpass);
        $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
        return $pdo;
    } catch (PDOException $e) {
        http_response_code(500);
        echo json_encode([
            'success' => false,
            'message' => 'Database connection failed: ' . $e->getMessage()
        ]);
        exit();
    }
}

function getInputData() {
    return json_decode(file_get_contents('php://input'), true);
}

function generateToken($userId, $username) {
    $header = base64_encode(json_encode(['alg' => 'HS256', 'typ' => 'JWT']));
    $payload = base64_encode(json_encode(['user_id' => $userId, 'username' => $username, 'exp' => time() + 3600]));
    $signature = hash_hmac('sha256', "$header.$payload", 'secretkey', true);
    $signature = base64_encode($signature);
    return "$header.$payload.$signature";
}

function verifyToken($token) {
    try {
        list($header, $payload, $signature) = explode('.', $token);
        $expectedSignature = base64_encode(hash_hmac('sha256', "$header.$payload", 'secretkey', true));
        if ($signature !== $expectedSignature) return false;
        $data = json_decode(base64_decode($payload), true);
        if ($data['exp'] < time()) return false;
        return $data;
    } catch (Exception $e) {
        return false;
    }
}

$uri = parse_url($_SERVER['REQUEST_URI'], PHP_URL_PATH);
$method = $_SERVER['REQUEST_METHOD'];

$pdo = getDBConnection($host, $dbname, $dbuser, $dbpass);

if ($uri === '/' && $method === 'GET') {
    echo json_encode([
        'success' => true,
        'message' => 'API Server Running',
        'endpoints' => [
            'POST /api/register' => 'User registration',
            'POST /api/login' => 'User login',
            'GET /api/profile' => 'Get user profile (requires token)',
            'GET /api/info' => 'Server info'
        ]
    ]);
    exit();
}

if ($uri === '/api/register' && $method === 'POST') {
    $data = getInputData();
    if (!isset($data['username']) || !isset($data['email']) || !isset($data['password'])) {
        http_response_code(400);
        echo json_encode(['success' => false, 'message' => 'All fields are required']);
        exit();
    }

    $hashedPassword = password_hash($data['password'], PASSWORD_DEFAULT);

    try {
        $stmt = $pdo->prepare("INSERT INTO users (username, email, password) VALUES (?, ?, ?)");
        $stmt->execute([$data['username'], $data['email'], $hashedPassword]);
        echo json_encode([
            'success' => true,
            'message' => 'User registered successfully',
            'data' => ['user_id' => $pdo->lastInsertId(), 'username' => $data['username']]
        ]);
    } catch (PDOException $e) {
        http_response_code(409);
        echo json_encode(['success' => false, 'message' => 'Username or email already exists']);
    }
    exit();
}

if ($uri === '/api/login' && $method === 'POST') {
    $data = getInputData();
    if (!isset($data['username']) || !isset($data['password'])) {
        http_response_code(400);
        echo json_encode(['success' => false, 'message' => 'Username and password are required']);
        exit();
    }

    try {
        $stmt = $pdo->prepare("SELECT * FROM users WHERE username = ?");
        $stmt->execute([$data['username']]);
        $user = $stmt->fetch(PDO::FETCH_ASSOC);

        if ($user && password_verify($data['password'], $user['password'])) {
            $token = generateToken($user['id'], $user['username']);
            echo json_encode([
                'success' => true,
                'message' => 'Login successful',
                'data' => [
                    'token' => $token,
                    'user' => [
                        'id' => $user['id'],
                        'username' => $user['username'],
                        'email' => $user['email']
                    ]
                ]
            ]);
        } else {
            http_response_code(401);
            echo json_encode(['success' => false, 'message' => 'Invalid username or password']);
        }
    } catch (PDOException $e) {
        http_response_code(500);
        echo json_encode(['success' => false, 'message' => 'Login failed']);
    }
    exit();
}

if ($uri === '/api/profile' && $method === 'GET') {
    $headers = getallheaders();
    $authHeader = $headers['Authorization'] ?? '';
    if (!preg_match('/Bearer\s+(.*)$/i', $authHeader, $matches)) {
        http_response_code(401);
        echo json_encode(['success' => false, 'message' => 'Authorization token required']);
        exit();
    }

    $tokenData = verifyToken($matches[1]);
    if (!$tokenData) {
        http_response_code(401);
        echo json_encode(['success' => false, 'message' => 'Invalid or expired token']);
        exit();
    }

    try {
        $stmt = $pdo->prepare("SELECT id, username, email, created_at FROM users WHERE id = ?");
        $stmt->execute([$tokenData['user_id']]);
        $user = $stmt->fetch(PDO::FETCH_ASSOC);
        echo json_encode(['success' => true, 'data' => $user]);
    } catch (PDOException $e) {
        http_response_code(500);
        echo json_encode(['success' => false, 'message' => 'Failed to get profile']);
    }
    exit();
}

if ($uri === '/api/info' && $method === 'GET') {
    echo json_encode([
        'success' => true,
        'data' => [
            'server' => 'PHP Native',
            'mode' => 'Dengan Nginx Proxy',
            'time' => date('Y-m-d H:i:s'),
            'database' => 'MySQL',
            'proxy_headers' => [
                'X-Forwarded-For' => $_SERVER['HTTP_X_FORWARDED_FOR'] ?? 'Tidak tersedia',
                'X-Forwarded-Proto' => $_SERVER['HTTP_X_FORWARDED_PROTO'] ?? 'Tidak tersedia'
            ]
        ]
    ]);
    exit();
}

http_response_code(404);
echo json_encode([
    'success' => false,
    'message' => 'Endpoint tidak ditemukan'
]);

