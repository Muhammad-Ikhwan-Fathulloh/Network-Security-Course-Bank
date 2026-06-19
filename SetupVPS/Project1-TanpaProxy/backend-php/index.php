<?php
// Enable error reporting untuk debugging
error_reporting(E_ALL);
ini_set('display_errors', 1);

header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type');

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit();
}

$products = [
    ['id' => 1, 'name' => 'Laptop Gaming', 'price' => 15000000],
    ['id' => 2, 'name' => 'Mouse Wireless', 'price' => 500000],
    ['id' => 3, 'name' => 'Keyboard Mechanical', 'price' => 1200000],
    ['id' => 4, 'name' => 'Monitor 27 Inch', 'price' => 3000000]
];

// Ambil path dari request dengan benar
$request_uri = $_SERVER['REQUEST_URI'];
$script_name = $_SERVER['SCRIPT_NAME'];

// Hapus query string
if (strpos($request_uri, '?') !== false) {
    $request_uri = substr($request_uri, 0, strpos($request_uri, '?'));
}

// Dapatkan path relatif
$path = str_replace($script_name, '', $request_uri);
$path = trim($path, '/');
$method = $_SERVER['REQUEST_METHOD'];

// Log untuk debugging
error_log("=== Request Debug ===");
error_log("REQUEST_URI: " . $_SERVER['REQUEST_URI']);
error_log("SCRIPT_NAME: " . $_SERVER['SCRIPT_NAME']);
error_log("Path: " . $path);

// Routing manual
if (empty($path)) {
    // Root path - return API info
    echo json_encode([
        'success' => true,
        'message' => 'API Server Running',
        'endpoints' => [
            'GET /api/products' => 'Get all products',
            'GET /api/products/{id}' => 'Get product by ID',
            'GET /api/info' => 'Server info'
        ]
    ]);
    exit();
}

// Parse path
$segments = explode('/', $path);

// Route: /api/products
if ($segments[0] === 'api' && isset($segments[1]) && $segments[1] === 'products') {
    if ($method === 'GET') {
        // GET /api/products/{id}
        if (isset($segments[2]) && is_numeric($segments[2])) {
            $id = (int)$segments[2];
            $product = null;
            foreach ($products as $p) {
                if ($p['id'] === $id) {
                    $product = $p;
                    break;
                }
            }
            if ($product) {
                echo json_encode([
                    'success' => true,
                    'data' => $product,
                    'message' => 'Produk ditemukan'
                ]);
            } else {
                http_response_code(404);
                echo json_encode([
                    'success' => false,
                    'message' => 'Produk tidak ditemukan'
                ]);
            }
        } else {
            // GET /api/products
            echo json_encode([
                'success' => true,
                'data' => $products,
                'message' => 'Data produk berhasil diambil'
            ]);
        }
    } else {
        http_response_code(405);
        echo json_encode([
            'success' => false,
            'message' => 'Method tidak diizinkan'
        ]);
    }
}
// Route: /api/info
elseif ($segments[0] === 'api' && isset($segments[1]) && $segments[1] === 'info') {
    echo json_encode([
        'success' => true,
        'data' => [
            'server' => 'PHP Native',
            'mode' => 'Direct Access (Tanpa Proxy)',
            'time' => date('Y-m-d H:i:s'),
            'php_version' => phpversion()
        ]
    ]);
}
// Route tidak ditemukan
else {
    http_response_code(404);
    echo json_encode([
        'success' => false,
        'message' => 'Endpoint tidak ditemukan',
        'path' => $path,
        'available_endpoints' => [
            '/api/products',
            '/api/products/{id}',
            '/api/info'
        ]
    ]);
}