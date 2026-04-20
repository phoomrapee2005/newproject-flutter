# คู่มือการเชื่อมต่อ TiDB และ DBeaver กับ Click & Clack

## ส่วนที่ 1: การติดตั้งและตั้งค่า TiDB

### 1.1 ติดตั้ง TiDB (Local Development)

#### วิธีที่ 1: ใช้ TiUP (แนะนำ)
```bash
# ติดตั้ง TiUP
curl --proto '=https' --tlsv1.2 -sSf https://tiup-mirrors.pingcap.com/install.sh | sh

# รีโหลด shell
source ~/.profile

# ติดตั้ง TiDB cluster สำหรับ development
tiup playground nightly
```

#### วิธีที่ 2: ใช้ Docker
```bash
docker run --name tidb -p 4000:4000 pingcap/tidb:latest
```

### 1.2 ข้อมูลการเชื่อมต่อ TiDB Default
```
Host: localhost
Port: 4000
User: root
Password: (ว่าง)
Database: click_clack
```

---

## ส่วนที่ 2: การติดตั้ง DBeaver

### 2.1 ดาวน์โหลดและติดตั้ง
1. ไปที่ https://dbeaver.io/download/
2. ดาวน์โหลด DBeaver Community (ฟรี)
3. ติดตั้งตามขั้นตอน

### 2.2 เพิ่ม MySQL Driver ใน DBeaver
1. เปิด DBeaver
2. ไปที่ **Database** > **Driver Manager**
3. ค้นหา **MySQL** และติดตั้ง

---

## ส่วนที่ 3: การเชื่อมต่อ DBeaver กับ TiDB

### 3.1 สร้าง Connection ใหม่
1. คลิก **Database** > **New Database Connection**
2. เลือก **MySQL** (TiDB ใช้ MySQL Protocol)
3. กรอกข้อมูล:

```
Host: localhost
Port: 4000
Database: click_clack
Username: root
Password: (ปล่อยว่าง)
```

4. คลิก **Test Connection**
5. คลิก **Finish**

### 3.2 สร้าง Database และ Tables

เปิด SQL Editor ใน DBeaver แล้วรันคำสั่ง:

```sql
-- สร้าง Database
CREATE DATABASE IF NOT EXISTS click_clack;
USE click_clack;

-- ตาราง products
CREATE TABLE IF NOT EXISTS products (
    id VARCHAR(36) PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    seller_name VARCHAR(100) NOT NULL,
    seller_phone VARCHAR(20) NOT NULL,
    banner VARCHAR(255),
    category VARCHAR(50) NOT NULL,
    model_name VARCHAR(100) NOT NULL,
    description TEXT,
    condition VARCHAR(10) NOT NULL,
    quantity INT NOT NULL DEFAULT 0,
    price DECIMAL(10,2) NOT NULL,
    image_path VARCHAR(500),
    created_at DATETIME NOT NULL
);

-- ตาราง orders
CREATE TABLE IF NOT EXISTS orders (
    id VARCHAR(36) PRIMARY KEY,
    items JSON NOT NULL,
    customer_name VARCHAR(100) NOT NULL,
    customer_phone VARCHAR(20) NOT NULL,
    address TEXT NOT NULL,
    postal_code VARCHAR(10) NOT NULL,
    shipping_type VARCHAR(20) NOT NULL,
    shipping_fee DECIMAL(10,2) NOT NULL,
    total_price DECIMAL(10,2) NOT NULL,
    order_date DATETIME NOT NULL,
    payment_method VARCHAR(50) NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'pending'
);

-- สร้าง indexes
CREATE INDEX idx_products_category ON products(category);
CREATE INDEX idx_products_condition ON products(condition);
CREATE INDEX idx_orders_date ON orders(order_date DESC);
```

---

## ส่วนที่ 4: การเชื่อมต่อ Flutter กับ TiDB

### 4.1 สร้างไฟล์ Service สำหรับเชื่อมต่อ API

สร้างไฟล์ `lib/services/api_service.dart`:

```dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/product.dart';
import '../models/order.dart';

class ApiService {
  // เปลี่ยนเป็น IP ของ TiDB server
  static const String baseUrl = 'http://localhost:8080/api';

  // Products
  Future<List<Product>> getProducts() async {
    final response = await http.get(Uri.parse('$baseUrl/products'));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((e) => Product.fromMap(e)).toList();
    }
    throw Exception('Failed to load products');
  }

  Future<Product> createProduct(Product product) async {
    final response = await http.post(
      Uri.parse('$baseUrl/products'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(product.toMap()),
    );
    if (response.statusCode == 201) {
      return Product.fromMap(json.decode(response.body));
    }
    throw Exception('Failed to create product');
  }

  Future<Product> updateProduct(Product product) async {
    final response = await http.put(
      Uri.parse('$baseUrl/products/${product.id}'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(product.toMap()),
    );
    if (response.statusCode == 200) {
      return Product.fromMap(json.decode(response.body));
    }
    throw Exception('Failed to update product');
  }

  Future<void> deleteProduct(String id) async {
    final response = await http.delete(Uri.parse('$baseUrl/products/$id'));
    if (response.statusCode != 200) {
      throw Exception('Failed to delete product');
    }
  }

  // Orders
  Future<List<Order>> getOrders() async {
    final response = await http.get(Uri.parse('$baseUrl/orders'));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((e) => Order.fromMap(e)).toList();
    }
    throw Exception('Failed to load orders');
  }

  Future<Order> createOrder(Order order) async {
    final response = await http.post(
      Uri.parse('$baseUrl/orders'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(order.toMap()),
    );
    if (response.statusCode == 201) {
      return Order.fromMap(json.decode(response.body));
    }
    throw Exception('Failed to create order');
  }
}
```

### 4.2 เพิ่ม HTTP package

ใน `pubspec.yaml`:
```yaml
dependencies:
  http: ^1.2.0
```

รัน:
```bash
flutter pub get
```

---

## ส่วนที่ 5: สร้าง Backend API (Node.js + TiDB)

### 5.1 โครงสร้างโปรเจค Backend

```
click_clack_backend/
├── package.json
├── .env
└── src/
    ├── index.js
    ├── database.js
    ├── routes/
    │   ├── products.js
    │   └── orders.js
    └── models/
```

### 5.2 ติดตั้ง Dependencies

```bash
npm init -y
npm install express mysql2 cors dotenv body-parser
```

### 5.3 ไฟล์ `.env`

```env
TIDB_HOST=localhost
TIDB_PORT=4000
TIDB_USER=root
TIDB_PASSWORD=
TIDB_DATABASE=click_clack
PORT=8080
```

### 5.4 ไฟล์ `src/database.js`

```javascript
const mysql = require('mysql2/promise');
require('dotenv').config();

const pool = mysql.createPool({
  host: process.env.TIDB_HOST,
  port: parseInt(process.env.TIDB_PORT),
  user: process.env.TIDB_USER,
  password: process.env.TIDB_PASSWORD,
  database: process.env.TIDB_DATABASE,
  waitForConnections: true,
  connectionLimit: 10,
  queueLimit: 0,
});

module.exports = pool;
```

### 5.5 ไฟล์ `src/index.js`

```javascript
const express = require('express');
const cors = require('cors');
const bodyParser = require('body-parser');
require('dotenv').config();

const productsRouter = require('./routes/products');
const ordersRouter = require('./routes/orders');

const app = express();

app.use(cors());
app.use(bodyParser.json());
app.use(bodyParser.urlencoded({ extended: true }));

app.use('/api/products', productsRouter);
app.use('/api/orders', ordersRouter);

const PORT = process.env.PORT || 8080;
app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});
```

### 5.6 ไฟล์ `src/routes/products.js`

```javascript
const express = require('express');
const router = express.Router();
const pool = require('../database');

// GET all products
router.get('/', async (req, res) => {
  try {
    const [rows] = await pool.query('SELECT * FROM products ORDER BY created_at DESC');
    res.json(rows);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// GET product by ID
router.get('/:id', async (req, res) => {
  try {
    const [rows] = await pool.query('SELECT * FROM products WHERE id = ?', [req.params.id]);
    if (rows.length === 0) {
      return res.status(404).json({ error: 'Product not found' });
    }
    res.json(rows[0]);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// POST create product
router.post('/', async (req, res) => {
  try {
    const { id, name, seller_name, seller_phone, banner, category, model_name, 
            description, condition, quantity, price, image_path, created_at } = req.body;
    
    await pool.query(
      `INSERT INTO products (id, name, seller_name, seller_phone, banner, category, 
         model_name, description, condition, quantity, price, image_path, created_at) 
       VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`,
      [id, name, seller_name, seller_phone, banner, category, model_name, 
       description, condition, quantity, price, image_path, created_at]
    );
    
    res.status(201).json({ message: 'Product created' });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// PUT update product
router.put('/:id', async (req, res) => {
  try {
    const { name, seller_name, seller_phone, banner, category, model_name, 
            description, condition, quantity, price, image_path } = req.body;
    
    await pool.query(
      `UPDATE products SET name=?, seller_name=?, seller_phone=?, banner=?, 
         category=?, model_name=?, description=?, condition=?, quantity=?, 
         price=?, image_path=? WHERE id=?`,
      [name, seller_name, seller_phone, banner, category, model_name, 
       description, condition, quantity, price, image_path, req.params.id]
    );
    
    res.json({ message: 'Product updated' });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// DELETE product
router.delete('/:id', async (req, res) => {
  try {
    await pool.query('DELETE FROM products WHERE id = ?', [req.params.id]);
    res.json({ message: 'Product deleted' });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

module.exports = router;
```

### 5.7 ไฟล์ `src/routes/orders.js`

```javascript
const express = require('express');
const router = express.Router();
const pool = require('../database');

// GET all orders
router.get('/', async (req, res) => {
  try {
    const [rows] = await pool.query('SELECT * FROM orders ORDER BY order_date DESC');
    res.json(rows);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// POST create order
router.post('/', async (req, res) => {
  try {
    const { id, items, customer_name, customer_phone, address, postal_code, 
            shipping_type, shipping_fee, total_price, order_date, payment_method, status } = req.body;
    
    await pool.query(
      `INSERT INTO orders (id, items, customer_name, customer_phone, address, 
         postal_code, shipping_type, shipping_fee, total_price, order_date, 
         payment_method, status) 
       VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`,
      [id, JSON.stringify(items), customer_name, customer_phone, address, 
       postal_code, shipping_type, shipping_fee, total_price, order_date, 
       payment_method, status]
    );
    
    res.status(201).json({ message: 'Order created' });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

module.exports = router;
```

### 5.8 รัน Backend Server

```bash
node src/index.js
```

---

## ส่วนที่ 6: การทดสอบการเชื่อมต่อ

### 6.1 ทดสอบใน DBeaver

```sql
-- ดูสินค้าทั้งหมด
SELECT * FROM products;

-- ดูออเดอร์ทั้งหมด
SELECT * FROM orders;

-- ดูยอดขายรวม
SELECT SUM(total_price) as total_revenue FROM orders;

-- ดูสินค้าขายดี
SELECT p.name, COUNT(*) as order_count 
FROM orders o, JSON_TABLE(o.items, '$[*]' COLUMNS(
    product_id VARCHAR(36) PATH '$.product_id'
)) jt
JOIN products p ON jt.product_id = p.id
GROUP BY p.name
ORDER BY order_count DESC;
```

### 6.2 ทดสอบ API ด้วย Postman/curl

```bash
# GET products
curl http://localhost:8080/api/products

# POST product
curl -X POST http://localhost:8080/api/products \
  -H "Content-Type: application/json" \
  -d '{
    "id": "uuid-123",
    "name": "Test Mouse",
    "seller_name": "Test Seller",
    "seller_phone": "0812345678",
    "banner": "Gaming Mouse",
    "category": "เมาส์",
    "model_name": "MX Master 3",
    "description": "Wireless mouse",
    "condition": "new",
    "quantity": 10,
    "price": 3500,
    "image_path": "/path/to/image.jpg",
    "created_at": "2026-04-20T10:00:00.000Z"
  }'
```

---

## ส่วนที่ 7: แผนภาพสถาปัตยกรรม

```
┌─────────────────┐     HTTP/REST     ┌─────────────────┐
│   Flutter App   │◄─────────────────►│   Node.js API   │
│  (Click & Clack)│                   │    Backend      │
└─────────────────┘                   └────────┬────────┘
                                               │
                                               │ MySQL Protocol
                                               ▼
                                      ┌─────────────────┐
                                      │      TiDB       │
                                      │   Database      │
                                      └────────┬────────┘
                                               │
                                               │ MySQL Protocol
                                               ▼
                                      ┌─────────────────┐
                                      │     DBeaver     │
                                      │   (View/Edit)   │
                                      └─────────────────┘
```

---

## ส่วนที่ 8: การแก้ปัญหาที่พบบ่อย

| ปัญหา | วิธีแก้ |
|-------|---------|
| Connection refused | ตรวจสอบว่า TiDB ทำงานอยู่และ port 4000 ว่าง |
| Access denied | ตรวจสอบ username/password ใน .env |
| CORS error | ตรวจสอบว่า backend มี cors() enabled |
| Timeout | เพิ่ม timeout ใน database connection |

---

## สรุปขั้นตอน

1. ✅ ติดตั้ง TiDB (TiUP หรือ Docker)
2. ✅ ติดตั้ง DBeaver
3. ✅ สร้าง connection ใน DBeaver ไปยัง TiDB
4. ✅ สร้าง database และ tables
5. ✅ สร้าง Node.js backend API
6. ✅ แก้ไข Flutter app ให้ใช้ API แทน SQLite
7. ✅ ทดสอบการเชื่อมต่อทั้งหมด
