-- =====================================================
-- Click & Clack Database Schema
-- สำหรับ TiDB / MySQL
-- =====================================================

-- สร้าง Database
CREATE DATABASE IF NOT EXISTS click_clack
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

USE click_clack;

-- =====================================================
-- ตาราง Products (สินค้า)
-- =====================================================
DROP TABLE IF EXISTS products;

CREATE TABLE products (
    id VARCHAR(36) PRIMARY KEY COMMENT 'UUID',
    name VARCHAR(255) NOT NULL COMMENT 'ชื่อสินค้า',
    seller_name VARCHAR(100) NOT NULL COMMENT 'ชื่อผู้ขาย',
    seller_phone VARCHAR(20) NOT NULL COMMENT 'เบอร์ผู้ขาย',
    banner VARCHAR(255) DEFAULT '' COMMENT 'แบนเนอร์',
    category VARCHAR(50) NOT NULL COMMENT 'ประเภทสินค้า',
    model_name VARCHAR(100) NOT NULL COMMENT 'ชื่อรุ่น',
    description TEXT COMMENT 'รายละเอียด',
    condition VARCHAR(10) NOT NULL COMMENT 'สภาพ: new หรือ used',
    quantity INT NOT NULL DEFAULT 0 COMMENT 'จำนวนคงเหลือ',
    price DECIMAL(10,2) NOT NULL COMMENT 'ราคา',
    image_path VARCHAR(500) DEFAULT '' COMMENT 'พาทรูปภาพ',
    created_at DATETIME NOT NULL COMMENT 'วันที่เพิ่ม',

    INDEX idx_category (category),
    INDEX idx_condition (condition),
    INDEX idx_price (price),
    INDEX idx_created_at (created_at DESC)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =====================================================
-- ตาราง Orders (ออเดอร์)
-- =====================================================
DROP TABLE IF EXISTS orders;

CREATE TABLE orders (
    id VARCHAR(36) PRIMARY KEY COMMENT 'UUID',
    items JSON NOT NULL COMMENT 'รายการสินค้า (JSON)',
    customer_name VARCHAR(100) NOT NULL COMMENT 'ชื่อลูกค้า',
    customer_phone VARCHAR(20) NOT NULL COMMENT 'เบอร์ลูกค้า',
    address TEXT NOT NULL COMMENT 'ที่อยู่',
    postal_code VARCHAR(10) NOT NULL COMMENT 'รหัสไปรษณีย์',
    shipping_type VARCHAR(20) NOT NULL COMMENT 'ประเภทจัดส่ง: normal หรือ express',
    shipping_fee DECIMAL(10,2) NOT NULL COMMENT 'ค่าจัดส่ง',
    total_price DECIMAL(10,2) NOT NULL COMMENT 'ราคารวม',
    order_date DATETIME NOT NULL COMMENT 'วันที่สั่งซื้อ',
    payment_method VARCHAR(50) NOT NULL DEFAULT 'bank_transfer' COMMENT 'วิธีชำระเงิน',
    status VARCHAR(20) NOT NULL DEFAULT 'pending' COMMENT 'สถานะ: pending, paid, shipping, completed, cancelled',

    INDEX idx_order_date (order_date DESC),
    INDEX idx_status (status),
    INDEX idx_customer_phone (customer_phone)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =====================================================
-- ตาราง Order Items (แยกจาก orders สำหรับ query ง่าย)
-- =====================================================
DROP TABLE IF EXISTS order_items;

CREATE TABLE order_items (
    id INT AUTO_INCREMENT PRIMARY KEY,
    order_id VARCHAR(36) NOT NULL,
    product_id VARCHAR(36) NOT NULL,
    product_name VARCHAR(255) NOT NULL,
    product_model VARCHAR(100),
    quantity INT NOT NULL,
    unit_price DECIMAL(10,2) NOT NULL,
    subtotal DECIMAL(10,2) NOT NULL,

    FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE CASCADE,
    INDEX idx_order_id (order_id),
    INDEX idx_product_id (product_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =====================================================
-- ข้อมูลตัวอย่าง (Sample Data)
-- =====================================================

-- สินค้าตัวอย่าง
INSERT INTO products (id, name, seller_name, seller_phone, banner, category, model_name, description, condition, quantity, price, image_path, created_at) VALUES
('uuid-001', 'Razer DeathAdder V3', 'ร้านเกมมิ่งเกียร์', '0812345678', 'Gaming Mouse', 'เมาส์', 'DeathAdder V3', 'เมาส์เกมมิ่งน้ำหนักเบา 59g เซนเซอร์ Focus Pro 30K', 'new', 50, 2590.00, '', NOW()),
('uuid-002', 'Logitech G Pro X Superlight', 'ร้านเกมมิ่งเกียร์', '0812345678', 'Pro Gaming', 'เมาส์', 'G Pro X Superlight', 'เมาส์ไร้สายสำหรับ eSports น้ำหนัก 63g', 'new', 30, 4290.00, '', NOW()),
('uuid-003', 'Razer BlackWidow V4', 'ร้านเกมมิ่งเกียร์', '0812345678', 'Mechanical Keyboard', 'คีย์บอร์ด', 'BlackWidow V4', 'คีย์บอร์ด Mechanical สวิตช์เขียว RGB Chroma', 'new', 25, 4990.00, '', NOW()),
('uuid-004', 'SteelSeries Apex Pro', 'ร้านเกมมิ่งเกียร์', '0812345678', 'Pro Keyboard', 'คีย์บอร์ด', 'Apex Pro TKL', 'คีย์บอร์ดปรับจุดกดได้ OLED Smart Display', 'new', 20, 6590.00, '', NOW()),
('uuid-005', 'HyperX Cloud II', 'ร้านเกมมิ่งเกียร์', '0812345678', 'Gaming Headset', 'หูฟัง', 'Cloud II', 'หูฟังเกมมิ่ง 7.1 Surround Sound', 'new', 40, 2990.00, '', NOW()),
('uuid-006', 'Logitech G733', 'ร้านเกมมิ่งเกียร์', '0812345678', 'Wireless Headset', 'หูฟัง', 'G733', 'หูฟังไร้สาย RGB น้ำหนักเบา 278g', 'new', 35, 3790.00, '', NOW()),
('uuid-007', 'Razer Goliathus Extended', 'ร้านเกมมิ่งเกียร์', '0812345678', 'Gaming Surface', 'แผ่นรองเมาส์', 'Goliathus Extended', 'แผ่นรองเมาส์ขนาด 920x294mm พื้นผิวควบคุม', 'new', 100, 590.00, '', NOW()),
('uuid-008', 'SteelSeries QcK', 'ร้านเกมมิ่งเกียร์', '0812345678', 'Gaming Surface', 'แผ่นรองเมาส์', 'QcK Heavy', 'แผ่นรองเมาส์ผ้าหนา 6mm', 'new', 80, 390.00, '', NOW()),
('uuid-009', 'Logitech MX Master 3S', 'ร้านเกมมิ่งเกียร์', '0812345678', 'Productivity Mouse', 'เมาส์', 'MX Master 3S', 'เมาส์ไร้สายสำหรับทำงาน 8K DPI', 'new', 45, 3690.00, '', NOW()),
('uuid-010', 'Razer Viper V2 Pro (มือ 2)', 'คุณสมชาย', '0898765432', 'Used Gaming', 'เมาส์', 'Viper V2 Pro', 'เมาส์ไร้สายน้ำหนัก 58g สภาพดี 95%', 'used', 1, 2800.00, '', NOW());

-- ออเดอร์ตัวอย่าง
INSERT INTO orders (id, items, customer_name, customer_phone, address, postal_code, shipping_type, shipping_fee, total_price, order_date, payment_method, status) VALUES
('order-001', '[{"product_id":"uuid-001","quantity":1,"product":{"name":"Razer DeathAdder V3","price":2590}}]', 'นายรักชาติ รักเกม', '0861234567', '123 ถ.สุขุมวิท แขวงคลองเตย เขตคลองเตย', '10110', 'normal', 50.00, 2640.00, NOW(), 'bank_transfer', 'completed'),
('order-002', '[{"product_id":"uuid-003","quantity":1,"product":{"name":"Razer BlackWidow V4","price":4990}},{"product_id":"uuid-007","quantity":2,"product":{"name":"Razer Goliathus Extended","price":590}}]', 'นางสาวเกมมิ่ง เกมมิ่ง', '0872345678', '456 ถ.พหลโยธิน แขวงสามเสนใน เขตพญาไท', '10400', 'express', 100.00, 6270.00, NOW(), 'bank_transfer', 'shipping'),
('order-003', '[{"product_id":"uuid-005","quantity":1,"product":{"name":"HyperX Cloud II","price":2990}}]', 'เด็กชายเกม เกมเมอร์', '0883456789', '789 ถ.วิสุทธิกษัตริย์ แขวงบางขุนพรหม เขตพระนคร', '10200', 'normal', 50.00, 3040.00, NOW(), 'bank_transfer', 'paid');

-- ข้อมูลใน order_items (แยกจาก orders)
INSERT INTO order_items (order_id, product_id, product_name, product_model, quantity, unit_price, subtotal) VALUES
('order-001', 'uuid-001', 'Razer DeathAdder V3', 'DeathAdder V3', 1, 2590.00, 2590.00),
('order-002', 'uuid-003', 'Razer BlackWidow V4', 'BlackWidow V4', 1, 4990.00, 4990.00),
('order-002', 'uuid-007', 'Razer Goliathus Extended', 'Goliathus Extended', 2, 590.00, 1180.00),
('order-003', 'uuid-005', 'HyperX Cloud II', 'Cloud II', 1, 2990.00, 2990.00);

-- =====================================================
-- Views สำหรับ Query ข้อมูล
-- =====================================================

-- View: สรุปยอดขาย
DROP VIEW IF EXISTS sales_summary;
CREATE VIEW sales_summary AS
SELECT
    DATE(order_date) as sale_date,
    COUNT(*) as total_orders,
    SUM(total_price) as total_revenue,
    AVG(total_price) as avg_order_value
FROM orders
WHERE status NOT IN ('cancelled')
GROUP BY DATE(order_date)
ORDER BY sale_date DESC;

-- View: สินค้าขายดี
DROP VIEW IF EXISTS top_products;
CREATE VIEW top_products AS
SELECT
    p.id,
    p.name,
    p.category,
    COUNT(oi.id) as times_sold,
    SUM(oi.quantity) as total_quantity_sold,
    SUM(oi.subtotal) as total_revenue
FROM products p
LEFT JOIN order_items oi ON p.id = oi.product_id
GROUP BY p.id, p.name, p.category
ORDER BY total_quantity_sold DESC;

-- View: สถานะออเดอร์
DROP VIEW IF EXISTS order_status_summary;
CREATE VIEW order_status_summary AS
SELECT
    status,
    COUNT(*) as order_count,
    SUM(total_price) as total_value
FROM orders
GROUP BY status;

-- =====================================================
-- Stored Procedures
-- =====================================================

DELIMITER //

-- Procedure: ลดจำนวนสินค้าเมื่อมีการสั่งซื้อ
DROP PROCEDURE IF EXISTS sp_reduce_stock//
CREATE PROCEDURE sp_reduce_stock(
    IN p_order_id VARCHAR(36)
)
BEGIN
    DECLARE done INT DEFAULT FALSE;
    DECLARE v_product_id VARCHAR(36);
    DECLARE v_quantity INT;
    DECLARE cur CURSOR FOR
        SELECT JSON_EXTRACT(items, '$[*].product_id'),
               JSON_EXTRACT(items, '$[*].quantity')
        FROM orders
        WHERE id = p_order_id;
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    -- Update stock logic here
END//

-- Procedure: คำนวณยอดขายรวม
DROP PROCEDURE IF EXISTS sp_calculate_revenue//
CREATE PROCEDURE sp_calculate_revenue(
    IN p_start_date DATE,
    IN p_end_date DATE
)
BEGIN
    SELECT
        SUM(total_price) as total_revenue,
        COUNT(*) as total_orders
    FROM orders
    WHERE order_date BETWEEN p_start_date AND p_end_date
    AND status NOT IN ('cancelled');
END//

DELIMITER ;

-- =====================================================
-- Queries สำหรับทดสอบ
-- =====================================================

-- ดูสินค้าทั้งหมด
-- SELECT * FROM products;

-- ดูสินค้าแยกตามประเภท
-- SELECT category, COUNT(*) as count, AVG(price) as avg_price
-- FROM products GROUP BY category;

-- ดูสินค้ามือ 1 vs มือ 2
-- SELECT condition, COUNT(*) as count, AVG(price) as avg_price
-- FROM products GROUP BY condition;

-- ดูออเดอร์ทั้งหมด
-- SELECT * FROM orders ORDER BY order_date DESC;

-- ดูยอดขายรวม
-- SELECT SUM(total_price) as total_revenue FROM orders WHERE status != 'cancelled';

-- ดูสินค้าขายดี
-- SELECT * FROM top_products LIMIT 10;

-- ดูสรุปยอดขายรายวัน
-- SELECT * FROM sales_summary LIMIT 30;

-- =====================================================
-- End of Schema
-- =====================================================
