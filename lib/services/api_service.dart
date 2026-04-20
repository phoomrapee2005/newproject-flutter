import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/product.dart';
import '../models/order.dart';

class ApiService {
  // เปลี่ยน URL ตาม backend ที่รัน
  static const String baseUrl = 'http://localhost:8080/api';

  // Singleton pattern
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  final http.Client _client = http.Client();

  // ==================== PRODUCTS ====================

  /// ดึงสินค้าทั้งหมด
  Future<List<Product>> getProducts() async {
    try {
      final response = await _client.get(Uri.parse('$baseUrl/products'));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((e) => Product.fromMap(e)).toList();
      } else if (response.statusCode == 404) {
        return [];
      }
      throw Exception('Failed to load products: ${response.statusCode}');
    } catch (e) {
      print('Error fetching products: $e');
      return [];
    }
  }

  /// ดึงสินค้าตาม ID
  Future<Product?> getProduct(String id) async {
    try {
      final response = await _client.get(Uri.parse('$baseUrl/products/$id'));
      if (response.statusCode == 200) {
        return Product.fromMap(json.decode(response.body));
      }
      return null;
    } catch (e) {
      print('Error fetching product: $e');
      return null;
    }
  }

  /// เพิ่มสินค้าใหม่
  Future<bool> createProduct(Product product) async {
    try {
      final response = await _client.post(
        Uri.parse('$baseUrl/products'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(product.toMap()),
      );
      if (response.statusCode == 201 || response.statusCode == 200) {
        return true;
      }
      print('Failed to create product: ${response.body}');
      return false;
    } catch (e) {
      print('Error creating product: $e');
      return false;
    }
  }

  /// แก้ไขสินค้า
  Future<bool> updateProduct(Product product) async {
    try {
      final response = await _client.put(
        Uri.parse('$baseUrl/products/${product.id}'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(product.toMap()),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      }
      print('Failed to update product: ${response.body}');
      return false;
    } catch (e) {
      print('Error updating product: $e');
      return false;
    }
  }

  /// ลบสินค้า
  Future<bool> deleteProduct(String id) async {
    try {
      final response = await _client.delete(Uri.parse('$baseUrl/products/$id'));
      if (response.statusCode == 200 || response.statusCode == 204) {
        return true;
      }
      print('Failed to delete product: ${response.body}');
      return false;
    } catch (e) {
      print('Error deleting product: $e');
      return false;
    }
  }

  // ==================== ORDERS ====================

  /// ดึงออเดอร์ทั้งหมด
  Future<List<Order>> getOrders() async {
    try {
      final response = await _client.get(Uri.parse('$baseUrl/orders'));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((e) => Order.fromMap(e)).toList();
      } else if (response.statusCode == 404) {
        return [];
      }
      throw Exception('Failed to load orders: ${response.statusCode}');
    } catch (e) {
      print('Error fetching orders: $e');
      return [];
    }
  }

  /// สร้างออเดอร์ใหม่
  Future<bool> createOrder(Order order) async {
    try {
      final response = await _client.post(
        Uri.parse('$baseUrl/orders'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(order.toMap()),
      );
      if (response.statusCode == 201 || response.statusCode == 200) {
        return true;
      }
      print('Failed to create order: ${response.body}');
      return false;
    } catch (e) {
      print('Error creating order: $e');
      return false;
    }
  }

  /// ยกเลิกการเชื่อมต่อ
  void dispose() {
    _client.close();
  }
}
