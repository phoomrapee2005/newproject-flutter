import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/product.dart';
import '../providers/product_provider.dart';

class AddProductScreen extends StatefulWidget {
  final Product? product;

  const AddProductScreen({super.key, this.product});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _sellerNameController = TextEditingController();
  final _sellerPhoneController = TextEditingController();
  final _bannerController = TextEditingController();
  final _modelNameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _quantityController = TextEditingController();

  late String _category;
  late String _condition;
  XFile? _imageFile;
  bool _isLoading = false;

  final List<String> _categories = ['Mouse', 'Keyboard', 'Headphones', 'Mousepad', 'Others'];
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _category = widget.product?.category ?? 'Mouse';
    _condition = widget.product?.condition ?? 'new';
    
    if (widget.product != null) {
      _nameController.text = widget.product!.name;
      _sellerNameController.text = widget.product!.sellerName;
      _sellerPhoneController.text = widget.product!.sellerPhone;
      _bannerController.text = widget.product!.banner;
      _modelNameController.text = widget.product!.modelName;
      _descriptionController.text = widget.product!.description;
      _priceController.text = widget.product!.price.toString();
      _quantityController.text = widget.product!.quantity.toString();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _sellerNameController.dispose();
    _sellerPhoneController.dispose();
    _bannerController.dispose();
    _modelNameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (image != null) {
      setState(() {
        _imageFile = image;
      });
    }
  }

  Future<void> _saveProduct() async {
    if (!_formKey.currentState!.validate()) return;
    if (_imageFile == null && widget.product == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a product image'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    final quantity = int.tryParse(_quantityController.text) ?? 0;
    final price = double.tryParse(_priceController.text) ?? 0.0;

    final product = Product(
      id: widget.product?.id ?? const Uuid().v4(),
      name: _nameController.text,
      sellerName: _sellerNameController.text,
      sellerPhone: _sellerPhoneController.text,
      banner: _bannerController.text,
      category: _category,
      modelName: _modelNameController.text,
      description: _descriptionController.text,
      condition: _condition,
      quantity: quantity,
      price: price,
      imagePath: _imageFile?.path ?? widget.product?.imagePath ?? '',
      createdAt: widget.product?.createdAt ?? DateTime.now(),
    );

    try {
      if (widget.product == null) {
        await Provider.of<ProductProvider>(context, listen: false).addProduct(product);
      } else {
        await Provider.of<ProductProvider>(context, listen: false).updateProduct(product);
      }

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.product == null ? 'Product posted!' : 'Product updated!'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.green[700],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.product != null;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text(isEdit ? 'Edit Post' : 'New Post'),
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            // Image Picker Card
            _buildImagePicker(),
            const SizedBox(height: 32),

            _buildSectionHeader('Product Details', Icons.inventory_2_rounded),
            const SizedBox(height: 20),
            
            _buildTextField(
              controller: _nameController,
              label: 'Product Name',
              icon: Icons.shopping_bag_outlined,
              validator: (v) => v!.isEmpty ? 'Enter name' : null,
            ),
            const SizedBox(height: 16),
            
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    controller: _modelNameController,
                    label: 'Model',
                    icon: Icons.tag_rounded,
                    validator: (v) => v!.isEmpty ? 'Enter model' : null,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildDropdown(
                    value: _category,
                    label: 'Category',
                    items: _categories,
                    onChanged: (v) => setState(() => _category = v!),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    controller: _priceController,
                    label: 'Price',
                    icon: Icons.payments_outlined,
                    keyboardType: TextInputType.number,
                    validator: (v) => v!.isEmpty ? 'Enter price' : null,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildTextField(
                    controller: _quantityController,
                    label: 'Quantity',
                    icon: Icons.stacked_bar_chart_rounded,
                    keyboardType: TextInputType.number,
                    validator: (v) => v!.isEmpty ? 'Enter quantity' : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            _buildDropdown(
              value: _condition,
              label: 'Condition',
              items: const ['new', 'used'],
              onChanged: (v) => setState(() => _condition = v!),
            ),
            const SizedBox(height: 16),

            _buildTextField(
              controller: _descriptionController,
              label: 'Description',
              icon: Icons.description_outlined,
              maxLines: 4,
            ),
            
            const SizedBox(height: 32),
            _buildSectionHeader('Seller Info', Icons.person_outline_rounded),
            const SizedBox(height: 20),

            _buildTextField(
              controller: _sellerNameController,
              label: 'Seller Name',
              icon: Icons.badge_outlined,
              validator: (v) => v!.isEmpty ? 'Enter seller name' : null,
            ),
            const SizedBox(height: 16),

            _buildTextField(
              controller: _sellerPhoneController,
              label: 'Contact Phone',
              icon: Icons.phone_android_rounded,
              keyboardType: TextInputType.phone,
              validator: (v) => v!.isEmpty ? 'Enter phone' : null,
            ),
            const SizedBox(height: 16),

            _buildTextField(
              controller: _bannerController,
              label: 'Store Banner/Note',
              icon: Icons.campaign_outlined,
            ),

            const SizedBox(height: 40),
            
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _saveProduct,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  backgroundColor: theme.colorScheme.primary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(strokeWidth: 3, color: Colors.white),
                      )
                    : Text(
                        isEdit ? 'SAVE CHANGES' : 'POST PRODUCT',
                        style: const TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.2),
                      ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: const Color(0xFF4361EE)),
        const SizedBox(width: 12),
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF1A1C23)),
        ),
      ],
    );
  }

  Widget _buildImagePicker() {
    return GestureDetector(
      onTap: _pickImage,
      child: Container(
        height: 240,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: const Color(0xFFF1F3F5)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(5),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: _imageFile != null
              ? (kIsWeb
                  ? Image.network(_imageFile!.path, fit: BoxFit.cover)
                  : Image.file(File(_imageFile!.path), fit: BoxFit.cover))
              : (widget.product?.imagePath.isNotEmpty == true
                  ? (kIsWeb || widget.product!.imagePath.startsWith('http')
                      ? Image.network(widget.product!.imagePath, fit: BoxFit.cover)
                      : Image.file(File(widget.product!.imagePath), fit: BoxFit.cover))
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8F9FA),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.add_a_photo_rounded, size: 40, color: Colors.grey[400]),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Upload Product Photo',
                          style: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.w600),
                        ),
                      ],
                    )),
        ),
      ),
    ).animate().fadeIn().scale(begin: const Offset(0.95, 0.95));
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 20),
        alignLabelWithHint: true,
      ),
    );
  }

  Widget _buildDropdown({
    required String value,
    required String label,
    required List<String> items,
    required void Function(String?) onChanged,
  }) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      items: items.map((i) => DropdownMenuItem(
        value: i, 
        child: Text(i[0].toUpperCase() + i.substring(1))
      )).toList(),
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: const Icon(Icons.layers_outlined, size: 20),
      ),
    );
  }
}
