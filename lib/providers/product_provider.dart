import 'package:flutter/foundation.dart';
import '../models/product.dart';
import '../database/database_helper.dart';

class ProductProvider with ChangeNotifier {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  List<Product> _products = [];
  bool _isLoading = false;

  List<Product> get products => _products;
  bool get isLoading => _isLoading;

  Future<void> loadProducts() async {
    _isLoading = true;
    notifyListeners();

    _products = await _dbHelper.getAllProducts();

    _isLoading = false;
    notifyListeners();
  }

  Future<void> addProduct(Product product) async {
    await _dbHelper.insertProduct(product);
    await loadProducts();
  }

  Future<void> updateProduct(Product product) async {
    await _dbHelper.updateProduct(product);
    await loadProducts();
  }

  Future<void> deleteProduct(String id) async {
    await _dbHelper.deleteProduct(id);
    await loadProducts();
  }

  List<Product> searchProducts(String query) {
    if (query.isEmpty) return _products;
    return _products.where((p) => 
      p.name.toLowerCase().contains(query.toLowerCase()) || 
      p.modelName.toLowerCase().contains(query.toLowerCase()) ||
      p.category.toLowerCase().contains(query.toLowerCase())
    ).toList();
  }

  Product? getProductById(String id) {
    try {
      return _products.firstWhere((p) => p.id == id);
    } catch (e) {
      return null;
    }
  }

  List<Product> getProductsByCategory(String category) {
    return _products.where((p) => p.category == category).toList();
  }

  List<Product> getNewProducts() {
    return _products.where((p) => p.condition == 'new').toList();
  }

  List<Product> getUsedProducts() {
    return _products.where((p) => p.condition == 'used').toList();
  }
}
