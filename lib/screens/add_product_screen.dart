import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
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

  String _category = 'Mouse';
  String _condition = 'new';
  XFile? _imageFile;
  bool _isLoading = false;

  final List<String> _categories = ['Mouse', 'Keyboard', 'Headphones', 'Mousepad', 'Others'];
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    if (widget.product != null) {
      _nameController.text = widget.product!.name;
      _sellerNameController.text = widget.product!.sellerName;
      _sellerPhoneController.text = widget.product!.sellerPhone;
      _bannerController.text = widget.product!.banner;
      _modelNameController.text = widget.product!.modelName;
      _descriptionController.text = widget.product!.description;
      _priceController.text = widget.product!.price.toString();
      _quantityController.text = widget.product!.quantity.toString();
      _category = widget.product!.category;
      _condition = widget.product!.condition;
      if (widget.product!.imagePath.isNotEmpty) {
        _imageFile = XFile(widget.product!.imagePath);
      }
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
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
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
        const SnackBar(content: Text('Please select an image')),
      );
      return;
    }

    setState(() => _isLoading = true);

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
      quantity: int.parse(_quantityController.text),
      price: double.parse(_priceController.text),
      imagePath: _imageFile?.path ?? '',
      createdAt: widget.product?.createdAt ?? DateTime.now(),
    );

    if (widget.product == null) {
      await Provider.of<ProductProvider>(context, listen: false).addProduct(product);
    } else {
      await Provider.of<ProductProvider>(context, listen: false).updateProduct(product);
    }

    setState(() => _isLoading = false);

    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.product == null ? 'Product added successfully' : 'Product updated successfully'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.product != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Edit Product' : 'Add Product'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Image Picker
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: _imageFile != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: kIsWeb
                            ? Image.network(_imageFile!.path, fit: BoxFit.cover)
                            : Image.file(File(_imageFile!.path), fit: BoxFit.cover),
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_photo_alternate, size: 48, color: Colors.grey[600]),
                          const SizedBox(height: 8),
                          Text(
                            'Tap to select image',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: 16),

            // Product Name
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Product Name *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.shopping_bag),
              ),
              validator: (v) => v!.isEmpty ? 'Please enter product name' : null,
            ),
            const SizedBox(height: 16),

            // Seller Info
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _sellerNameController,
                    decoration: const InputDecoration(
                      labelText: 'Seller Name *',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.person),
                    ),
                    validator: (v) => v!.isEmpty ? 'Please enter seller name' : null,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _sellerPhoneController,
                    decoration: const InputDecoration(
                      labelText: 'Seller Phone *',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.phone),
                    ),
                    validator: (v) => v!.isEmpty ? 'Please enter seller phone' : null,
                    keyboardType: TextInputType.phone,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Banner
            TextFormField(
              controller: _bannerController,
              decoration: const InputDecoration(
                labelText: 'Banner',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.flag),
              ),
            ),
            const SizedBox(height: 16),

            // Category
            DropdownButtonFormField<String>(
              initialValue: _category,
              decoration: const InputDecoration(
                labelText: 'Category',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.category),
              ),
              items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
              onChanged: (v) => setState(() => _category = v!),
            ),
            const SizedBox(height: 16),

            // Model Name
            TextFormField(
              controller: _modelNameController,
              decoration: const InputDecoration(
                labelText: 'Model Name *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.tag),
              ),
              validator: (v) => v!.isEmpty ? 'Please enter model name' : null,
            ),
            const SizedBox(height: 16),

            // Condition
            DropdownButtonFormField<String>(
              initialValue: _condition,
              decoration: const InputDecoration(
                labelText: 'Condition',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.info_outline),
              ),
              items: const [
                DropdownMenuItem(value: 'new', child: Text('New')),
                DropdownMenuItem(value: 'used', child: Text('Used')),
              ],
              onChanged: (v) => setState(() => _condition = v!),
            ),
            const SizedBox(height: 16),

            // Price and Quantity
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _priceController,
                    decoration: const InputDecoration(
                      labelText: 'Price *',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.attach_money),
                    ),
                    validator: (v) => v!.isEmpty ? 'Please enter price' : null,
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _quantityController,
                    decoration: const InputDecoration(
                      labelText: 'Quantity *',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.inventory),
                    ),
                    validator: (v) => v!.isEmpty ? 'Please enter quantity' : null,
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Description
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.description),
                alignLabelWithHint: true,
              ),
              maxLines: 4,
            ),
            const SizedBox(height: 24),

            // Save Button
            ElevatedButton(
              onPressed: _isLoading ? null : _saveProduct,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(
                      isEdit ? 'Save Changes' : 'Add Product',
                      style: const TextStyle(fontSize: 18),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
