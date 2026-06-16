<?php
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

$uri = parse_url($_SERVER['REQUEST_URI'], PHP_URL_PATH);
$method = $_SERVER['REQUEST_METHOD'];

if ($uri === '/api/products' && $method === 'GET') {
    echo json_encode([
        'success' => true,
        'data' => $products,
        'message' => 'Data produk berhasil diambil'
    ]);
} elseif (preg_match('#^/api/products/(\d+)$#', $uri, $matches) && $method === 'GET') {
    $id = (int)$matches[1];
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
} elseif ($uri === '/api/info' && $method === 'GET') {
    echo json_encode([
        'success' => true,
        'data' => [
            'server' => 'PHP Native',
            'mode' => 'Direct Access (Tanpa Proxy)',
            'time' => date('Y-m-d H:i:s')
        ]
    ]);
} else {
    http_response_code(404);
    echo json_encode([
        'success' => false,
        'message' => 'Endpoint tidak ditemukan'
    ]);
}
