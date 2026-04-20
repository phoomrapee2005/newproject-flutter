class Product {
  final String id;
  final String name;
  final String sellerName;
  final String sellerPhone;
  final String banner;
  final String category;
  final String modelName;
  final String description;
  final String condition; // 'new' or 'used'
  final int quantity;
  final double price;
  final String imagePath;
  final DateTime createdAt;

  Product({
    required this.id,
    required this.name,
    required this.sellerName,
    required this.sellerPhone,
    required this.banner,
    required this.category,
    required this.modelName,
    required this.description,
    required this.condition,
    required this.quantity,
    required this.price,
    required this.imagePath,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'seller_name': sellerName,
      'seller_phone': sellerPhone,
      'banner': banner,
      'category': category,
      'model_name': modelName,
      'description': description,
      'condition': condition,
      'quantity': quantity,
      'price': price,
      'image_path': imagePath,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'],
      name: map['name'],
      sellerName: map['seller_name'],
      sellerPhone: map['seller_phone'],
      banner: map['banner'],
      category: map['category'],
      modelName: map['model_name'],
      description: map['description'],
      condition: map['condition'],
      quantity: map['quantity'],
      price: map['price'],
      imagePath: map['image_path'],
      createdAt: DateTime.parse(map['created_at']),
    );
  }

  Product copyWith({
    String? id,
    String? name,
    String? sellerName,
    String? sellerPhone,
    String? banner,
    String? category,
    String? modelName,
    String? description,
    String? condition,
    int? quantity,
    double? price,
    String? imagePath,
    DateTime? createdAt,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      sellerName: sellerName ?? this.sellerName,
      sellerPhone: sellerPhone ?? this.sellerPhone,
      banner: banner ?? this.banner,
      category: category ?? this.category,
      modelName: modelName ?? this.modelName,
      description: description ?? this.description,
      condition: condition ?? this.condition,
      quantity: quantity ?? this.quantity,
      price: price ?? this.price,
      imagePath: imagePath ?? this.imagePath,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
