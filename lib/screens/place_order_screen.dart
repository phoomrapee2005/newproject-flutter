import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../providers/cart_provider.dart';
import '../providers/order_provider.dart';
import '../models/order.dart';
import '../models/cart_item.dart';

class PlaceOrderScreen extends StatefulWidget {
  const PlaceOrderScreen({super.key});

  @override
  State<PlaceOrderScreen> createState() => _PlaceOrderScreenState();
}

class _PlaceOrderScreenState extends State<PlaceOrderScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _postalCodeController = TextEditingController();

  String _shippingType = 'normal';
  double _shippingFee = 50;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _postalCodeController.dispose();
    super.dispose();
  }

  void _updateShippingFee(String? type) {
    setState(() {
      _shippingType = type ?? 'normal';
      _shippingFee = _shippingType == 'normal' ? 50 : 100;
    });
  }

  void _placeOrder(BuildContext context, CartProvider cartProvider) {
    if (!_formKey.currentState!.validate()) return;
    if (cartProvider.items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ตะกร้าสินค้าว่างเปล่า')),
      );
      return;
    }

    final itemsTotal = cartProvider.totalAmount;
    final totalPrice = itemsTotal + _shippingFee;

    final order = Order(
      id: const Uuid().v4(),
      items: cartProvider.items.map((item) => CartItem(
        product: item.product,
        quantity: item.quantity,
      )).toList(),
      customerName: _nameController.text,
      customerPhone: _phoneController.text,
      address: _addressController.text,
      postalCode: _postalCodeController.text,
      shippingType: _shippingType,
      shippingFee: _shippingFee,
      totalPrice: totalPrice,
      orderDate: DateTime.now(),
      paymentMethod: 'bank_transfer',
      status: 'pending',
    );

    Provider.of<OrderProvider>(context, listen: false).placeOrder(order);
    cartProvider.clearCart();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('สั่งซื้อสำเร็จ'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 64),
            const SizedBox(height: 16),
            const Text('ขอบคุณสำหรับการสั่งซื้อ'),
            const SizedBox(height: 8),
            Text('ยอดรวม: ${NumberFormat.currency(locale: "th_TH", symbol: "฿").format(totalPrice)}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Go back to cart
              Navigator.pop(context); // Go back to home
            },
            child: const Text('ตกลง'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(locale: 'th_TH', symbol: '฿');
    final cartProvider = Provider.of<CartProvider>(context);
    final itemsTotal = cartProvider.totalAmount;
    final totalPrice = itemsTotal + _shippingFee;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Place Order'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Customer Info Section
            const Text(
              'ข้อมูลผู้สั่งซื้อ',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'ชื่อ-นามสกุล *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
              validator: (v) => v!.isEmpty ? 'กรุณากรอกชื่อ' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _phoneController,
              decoration: const InputDecoration(
                labelText: 'เบอร์โทรศัพท์ *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.phone),
              ),
              validator: (v) => v!.isEmpty ? 'กรุณากรอกเบอร์โทรศัพท์' : null,
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _addressController,
              decoration: const InputDecoration(
                labelText: 'ที่อยู่ *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.home),
                alignLabelWithHint: true,
              ),
              maxLines: 3,
              validator: (v) => v!.isEmpty ? 'กรุณากรอกที่อยู่' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _postalCodeController,
              decoration: const InputDecoration(
                labelText: 'รหัสไปรษณีย์ *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.local_post_office),
              ),
              validator: (v) => v!.isEmpty ? 'กรุณากรอกรหัสไปรษณีย์' : null,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 24),

            // Shipping Section
            const Text(
              'การจัดส่ง',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Column(
              children: [
                RadioListTile<String>(
                  title: const Text('จัดส่งปกติ (2-3 วัน)'),
                  subtitle: const Text('ค่าส่ง 50 บาท'),
                  value: 'normal',
                  groupValue: _shippingType,
                  onChanged: (value) => _updateShippingFee(value),
                ),
                RadioListTile<String>(
                  title: const Text('จัดส่งด่วน (1 วัน)'),
                  subtitle: const Text('ค่าส่ง 100 บาท'),
                  value: 'express',
                  groupValue: _shippingType,
                  onChanged: (value) => _updateShippingFee(value),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Payment Section
            const Text(
              'ช่องทางการชำระเงิน',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.green),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.account_balance, color: Colors.white, size: 32),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'ธนาคารกสิกรไทย',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            Text(
                              'Click & Clack',
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 24),
                  const Text(
                    '1234567890',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'โปรดโอนชำระแล้วแนบหลักฐาน',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Order Summary
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  _buildSummaryRow('ค่าสินค้า', currencyFormat.format(itemsTotal)),
                  const SizedBox(height: 8),
                  _buildSummaryRow('ค่าจัดส่ง', currencyFormat.format(_shippingFee)),
                  const Divider(height: 24),
                  _buildSummaryRow(
                    'ยอดรวมทั้งหมด',
                    currencyFormat.format(totalPrice),
                    isTotal: true,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Place Order Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _placeOrder(context, cartProvider),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text(
                  'ยืนยันการสั่งซื้อ',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isTotal ? 18 : 16,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isTotal ? 20 : 16,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            color: isTotal ? Colors.red : null,
          ),
        ),
      ],
    );
  }
}
