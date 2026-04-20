import 'cart_item.dart';
import 'product.dart';

class Order {
  final String id;
  final List<CartItem> items;
  final String customerName;
  final String customerPhone;
  final String address;
  final String postalCode;
  final String shippingType; // 'normal' or 'express'
  final double shippingFee;
  final double totalPrice;
  final DateTime orderDate;
  final String paymentMethod;
  final String status;

  Order({
    required this.id,
    required this.items,
    required this.customerName,
    required this.customerPhone,
    required this.address,
    required this.postalCode,
    required this.shippingType,
    required this.shippingFee,
    required this.totalPrice,
    required this.orderDate,
    required this.paymentMethod,
    required this.status,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'items': items.map((item) => item.toMap()).toList(),
      'customer_name': customerName,
      'customer_phone': customerPhone,
      'address': address,
      'postal_code': postalCode,
      'shipping_type': shippingType,
      'shipping_fee': shippingFee,
      'total_price': totalPrice,
      'order_date': orderDate.toIso8601String(),
      'payment_method': paymentMethod,
      'status': status,
    };
  }

  factory Order.fromMap(Map<String, dynamic> map) {
    return Order(
      id: map['id'],
      items: (map['items'] as List).map((item) => CartItem(
        product: Product.fromMap(item['product']),
        quantity: item['quantity'],
      )).toList(),
      customerName: map['customer_name'],
      customerPhone: map['customer_phone'],
      address: map['address'],
      postalCode: map['postal_code'],
      shippingType: map['shipping_type'],
      shippingFee: map['shipping_fee'],
      totalPrice: map['total_price'],
      orderDate: DateTime.parse(map['order_date']),
      paymentMethod: map['payment_method'],
      status: map['status'],
    );
  }
}
