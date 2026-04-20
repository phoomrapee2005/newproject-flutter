import 'package:flutter/foundation.dart';
import '../models/order.dart';
import '../database/database_helper.dart';

class OrderProvider with ChangeNotifier {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  List<Order> _orders = [];
  bool _isLoading = false;

  List<Order> get orders => _orders;
  bool get isLoading => _isLoading;

  Future<void> loadOrders() async {
    _isLoading = true;
    notifyListeners();

    _orders = await _dbHelper.getAllOrders();

    _isLoading = false;
    notifyListeners();
  }

  Future<void> placeOrder(Order order) async {
    await _dbHelper.insertOrder(order);
    await loadOrders();
  }

  double getTotalSpent() {
    return _orders.fold(0, (sum, order) => sum + order.totalPrice);
  }

  int getOrderCount() {
    return _orders.length;
  }
}
