import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/product.dart';
import '../models/order.dart';

class ApiService {
  // Change URL based on backend
  static const String baseUrl = 'http://localhost:8080/api';

  // Singleton pattern
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  final http.Client _client = http.Client();

  // ==================== PRODUCTS ====================

  /// Fetch all products
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
      debugPrint('Error fetching products: $e');
      return [];
    }
  }

  /// Fetch product by ID
  Future<Product?> getProduct(String id) async {
    try {
      final response = await _client.get(Uri.parse('$baseUrl/products/$id'));
      if (response.statusCode == 200) {
        return Product.fromMap(json.decode(response.body));
      }
      return null;
    } catch (e) {
      debugPrint('Error fetching product: $e');
      return null;
    }
  }

  /// Create new product
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
      debugPrint('Failed to create product: ${response.body}');
      return false;
    } catch (e) {
      debugPrint('Error creating product: $e');
      return false;
    }
  }

  /// Update product
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
      debugPrint('Failed to update product: ${response.body}');
      return false;
    } catch (e) {
      debugPrint('Error updating product: $e');
      return false;
    }
  }

  /// Delete product
  Future<bool> deleteProduct(String id) async {
    try {
      final response = await _client.delete(Uri.parse('$baseUrl/products/$id'));
      if (response.statusCode == 200 || response.statusCode == 204) {
        return true;
      }
      debugPrint('Failed to delete product: ${response.body}');
      return false;
    } catch (e) {
      debugPrint('Error deleting product: $e');
      return false;
    }
  }

  // ==================== ORDERS ====================

  /// Fetch all orders
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
      debugPrint('Error fetching orders: $e');
      return [];
    }
  }

  /// Create new order
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
      debugPrint('Failed to create order: ${response.body}');
      return false;
    } catch (e) {
      debugPrint('Error creating order: $e');
      return false;
    }
  }

  /// Close connection
  void dispose() {
    _client.close();
  }
}
