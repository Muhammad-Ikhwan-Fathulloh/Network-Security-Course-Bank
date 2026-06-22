<?php
error_reporting(E_ALL);
ini_set('display_errors', 1);

header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Authorization');

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200); exit();
}

/**
 * DB CONNECTION & AUTO-TABLES
 */
function getDBConnection() {
    $db_path = '/var/www/html/database/database.sqlite';
    try {
        if (!is_dir(dirname($db_path))) mkdir(dirname($db_path), 0777, true);
        $pdo = new PDO("sqlite:$db_path");
        $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
        $pdo->exec("PRAGMA foreign_keys = ON;");
        
        $pdo->exec("CREATE TABLE IF NOT EXISTS users (id INTEGER PRIMARY KEY AUTOINCREMENT, username TEXT NOT NULL UNIQUE, email TEXT NOT NULL UNIQUE, password TEXT NOT NULL, created_at DATETIME DEFAULT CURRENT_TIMESTAMP)");
        $pdo->exec("CREATE TABLE IF NOT EXISTS categories (id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT NOT NULL UNIQUE)");
        $pdo->exec("CREATE TABLE IF NOT EXISTS products (id INTEGER PRIMARY KEY AUTOINCREMENT, category_id INTEGER, name TEXT NOT NULL, price REAL NOT NULL, stock INTEGER DEFAULT 0, FOREIGN KEY (category_id) REFERENCES categories (id))");
        $pdo->exec("CREATE TABLE IF NOT EXISTS transactions (id INTEGER PRIMARY KEY AUTOINCREMENT, user_id INTEGER, total REAL NOT NULL, created_at DATETIME DEFAULT CURRENT_TIMESTAMP, FOREIGN KEY (user_id) REFERENCES users (id))");
        $pdo->exec("CREATE TABLE IF NOT EXISTS transaction_details (id INTEGER PRIMARY KEY AUTOINCREMENT, transaction_id INTEGER, product_id INTEGER, quantity INTEGER NOT NULL, price_at_time REAL NOT NULL, FOREIGN KEY (transaction_id) REFERENCES transactions (id), FOREIGN KEY (product_id) REFERENCES products (id))");
        
        // Bootstrap Default Category
        $count = $pdo->query("SELECT COUNT(*) FROM categories")->fetchColumn();
        if ($count == 0) {
            $pdo->exec("INSERT INTO categories (name) VALUES ('Umum')");
        }
        
        return $pdo;
    } catch (Exception $e) {
        http_response_code(500); echo json_encode(['success' => false, 'message' => $e->getMessage()]); exit();
    }
}

$pdo = getDBConnection();
$uri = trim(parse_url($_SERVER['REQUEST_URI'], PHP_URL_PATH), '/');
$segments = explode('/', $uri);

if (empty($uri) || $uri === 'api') {
    echo json_encode(['success' => true, 'message' => 'POS API Engine v2 (SQLite)']); exit();
}

if ($segments[0] !== 'api') {
    http_response_code(404); exit();
}

$endpoint = $segments[1] ?? '';

/**
 * AUTH ENDPOINTS
 */
if ($endpoint === 'login' && $_SERVER['REQUEST_METHOD'] === 'POST') {
    $data = json_decode(file_get_contents('php://input'), true);
    $stmt = $pdo->prepare("SELECT * FROM users WHERE username = ?");
    $stmt->execute([$data['username']]);
    $user = $stmt->fetch(PDO::FETCH_ASSOC);
    if ($user && password_verify($data['password'], $user['password'])) {
        echo json_encode(['success' => true, 'data' => ['token' => base64_encode($user['id']), 'user' => $user]]);
    } else {
        http_response_code(401); echo json_encode(['success' => false, 'message' => 'Gagal']);
    }
}
elseif ($endpoint === 'register' && $_SERVER['REQUEST_METHOD'] === 'POST') {
    $data = json_decode(file_get_contents('php://input'), true);
    try {
        $stmt = $pdo->prepare("INSERT INTO users (username, email, password) VALUES (?, ?, ?)");
        $stmt->execute([$data['username'], $data['email'] ?? $data['username'].'@pos.com', password_hash($data['password'], PASSWORD_DEFAULT)]);
        echo json_encode(['success' => true]);
    } catch (Exception $e) { http_response_code(409); echo json_encode(['success' => false]); }
}
elseif ($endpoint === 'profile') {
    // Robust Authorization Header Retrieval
    $headers = apache_request_headers();
    $auth = $headers['Authorization'] ?? $headers['authorization'] ?? $_SERVER['HTTP_AUTHORIZATION'] ?? $_SERVER['REDIRECT_HTTP_AUTHORIZATION'] ?? '';
    
    $token = str_replace('Bearer ', '', $auth);
    $userId = base64_decode($token);
    
    if (!$userId) {
        http_response_code(401); echo json_encode(['success' => false, 'message' => 'Token invalid']); exit();
    }
    
    $stmt = $pdo->prepare("SELECT id, username, email, created_at FROM users WHERE id = ?");
    $stmt->execute([$userId]);
    $user = $stmt->fetch(PDO::FETCH_ASSOC);
    
    if ($user) {
        echo json_encode(['success' => true, 'data' => $user]);
    } else {
        http_response_code(401); echo json_encode(['success' => false, 'message' => 'Unauthorized']);
    }
}

/**
 * POS BUSINESS ENDPOINTS
 */
elseif ($endpoint === 'categories') {
    if ($_SERVER['REQUEST_METHOD'] === 'GET') {
        echo json_encode(['success' => true, 'data' => $pdo->query("SELECT * FROM categories")->fetchAll(PDO::FETCH_ASSOC)]);
    } elseif ($_SERVER['REQUEST_METHOD'] === 'POST') {
        try {
            $data = json_decode(file_get_contents('php://input'), true);
            if (empty($data['name'])) throw new Exception("Nama kategori harus diisi");
            
            $stmt = $pdo->prepare("INSERT INTO categories (name) VALUES (?)");
            $stmt->execute([$data['name']]);
            echo json_encode(['success' => true, 'id' => $pdo->lastInsertId()]);
        } catch (Exception $e) {
            http_response_code(400);
            echo json_encode(['success' => false, 'message' => "Gagal: " . $e->getMessage()]);
        }
    } elseif ($_SERVER['REQUEST_METHOD'] === 'DELETE') {
        $id = $segments[2] ?? 0;
        $pdo->prepare("DELETE FROM categories WHERE id = ?")->execute([$id]);
        echo json_encode(['success' => true]);
    }
}
elseif ($endpoint === 'products') {
    if ($_SERVER['REQUEST_METHOD'] === 'GET') {
        echo json_encode(['success' => true, 'data' => $pdo->query("SELECT p.*, c.name as category_name FROM products p LEFT JOIN categories c ON p.category_id = c.id")->fetchAll(PDO::FETCH_ASSOC)]);
    } elseif ($_SERVER['REQUEST_METHOD'] === 'POST') {
        try {
            $data = json_decode(file_get_contents('php://input'), true);
            $stmt = $pdo->prepare("INSERT INTO products (category_id, name, price, stock) VALUES (?, ?, ?, ?)");
            $stmt->execute([$data['category_id'], $data['name'], $data['price'], $data['stock']]);
            echo json_encode(['success' => true]);
        } catch (Exception $e) {
            http_response_code(400); echo json_encode(['success' => false, 'message' => $e->getMessage()]);
        }
    } elseif ($_SERVER['REQUEST_METHOD'] === 'PUT') {
        $id = $segments[2] ?? 0;
        $data = json_decode(file_get_contents('php://input'), true);
        $stmt = $pdo->prepare("UPDATE products SET name = ?, price = ?, stock = ?, category_id = ? WHERE id = ?");
        $stmt->execute([$data['name'], $data['price'], $data['stock'], $data['category_id'], $id]);
        echo json_encode(['success' => true]);
    } elseif ($_SERVER['REQUEST_METHOD'] === 'DELETE') {
        $id = $segments[2] ?? 0;
        $pdo->prepare("DELETE FROM products WHERE id = ?")->execute([$id]);
        echo json_encode(['success' => true]);
    }
}
elseif ($endpoint === 'transactions') {
    if ($_SERVER['REQUEST_METHOD'] === 'GET') {
        echo json_encode(['success' => true, 'data' => $pdo->query("SELECT * FROM transactions ORDER BY created_at DESC")->fetchAll(PDO::FETCH_ASSOC)]);
    } elseif ($_SERVER['REQUEST_METHOD'] === 'POST') {
        $data = json_decode(file_get_contents('php://input'), true); // {user_id, total, items: [{id, quantity, price}]}
        $pdo->beginTransaction();
        try {
            $stmt = $pdo->prepare("INSERT INTO transactions (user_id, total) VALUES (?, ?)");
            $stmt->execute([$data['user_id'] ?? 1, $data['total']]);
            $txId = $pdo->lastInsertId();
            
            $stmtDetail = $pdo->prepare("INSERT INTO transaction_details (transaction_id, product_id, quantity, price_at_time) VALUES (?, ?, ?, ?)");
            $stmtStock = $pdo->prepare("UPDATE products SET stock = stock - ? WHERE id = ?");
            
            foreach ($data['items'] as $item) {
                $stmtDetail->execute([$txId, $item['id'], $item['quantity'], $item['price']]);
                $stmtStock->execute([$item['quantity'], $item['id']]);
            }
            $pdo->commit();
            echo json_encode(['success' => true, 'transaction_id' => $txId]);
        } catch (Exception $e) { $pdo->rollBack(); http_response_code(500); echo json_encode(['success' => false, 'message' => $e->getMessage()]); }
    }
}
else {
    http_response_code(404); echo json_encode(['success' => false, 'message' => 'Endpoint mismatch']);
}
