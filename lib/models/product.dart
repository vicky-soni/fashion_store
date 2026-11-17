
class Product {
  final int? id;
  final String name;
  final String category;
  final String description;
  final double price;
  final String image;
  final int stock;
  final bool isNew;

  const Product({
    this.id,
    required this.name,
    required this.category,
    required this.description,
    required this.price,
    required this.image,
    this.stock = 20,
    this.isNew = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'description': description,
      'price': price,
      'image': image,
      'stock': stock,
      'is_new': isNew ? 1 : 0,
    };
  }

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'] as int?,
      name: map['name'] as String,
      category: map['category'] as String,
      description: map['description'] as String,
      price: (map['price'] as num).toDouble(),
      image: map['image'] as String,
      stock: map['stock'] as int,
      isNew: map['is_new'] == 1,
    );
  }
}
