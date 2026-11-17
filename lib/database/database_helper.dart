
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;

import '../models/product.dart';

class DatabaseHelper {
  DatabaseHelper._privateConstructor();

  static final DatabaseHelper instance =
      DatabaseHelper._privateConstructor();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = p.join(dbPath, 'fashion_store.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDatabase,
    );
  }

  Future<void> _createDatabase(Database db, int version) async {
    await db.execute('''
      CREATE TABLE products (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        category TEXT NOT NULL,
        description TEXT NOT NULL,
        price REAL NOT NULL,
        image TEXT NOT NULL,
        stock INTEGER NOT NULL,
        is_new INTEGER NOT NULL
      )
    ''');

    final products = [
      Product(
        name: 'Oversized T-Shirt',
        category: 'T-Shirts',
        description: 'Premium cotton oversized t-shirt for everyday comfort.',
        price: 599,
        image: 'assets/images/products/tshirt.jpg',
        isNew: true,
      ),
      Product(
        name: 'Classic Denim Jeans',
        category: 'Jeans',
        description: 'Stylish denim jeans with a comfortable fit.',
        price: 1199,
        image: 'assets/images/products/jeans.jpg',
      ),
      Product(
        name: 'Casual White Shirt',
        category: 'Shirts',
        description: 'Elegant white shirt for casual and formal occasions.',
        price: 899,
        image: 'assets/images/products/shirt.jpg',
        isNew: true,
      ),
      Product(
        name: 'Classic Hoodie',
        category: 'Hoodies',
        description: 'Comfortable hoodie with a modern streetwear look.',
        price: 1499,
        image: 'assets/images/products/hoodie.jpg',
      ),
      Product(
        name: 'Cotton Polo T-Shirt',
        category: 'T-Shirts',
        description: 'Soft cotton polo t-shirt with a classic design.',
        price: 749,
        image: 'assets/images/products/polo.jpg',
      ),
      Product(
        name: 'Cargo Pants',
        category: 'Trousers',
        description: 'Trendy cargo pants with multiple utility pockets.',
        price: 999,
        image: 'assets/images/products/cargo.jpg',
      ),
      Product(
        name: 'Formal Shirt',
        category: 'Shirts',
        description: 'Smart formal shirt for office and special occasions.',
        price: 1099,
        image: 'assets/images/products/formal.jpg',
      ),
      Product(
        name: 'Black Sweatshirt',
        category: 'Hoodies',
        description: 'Minimal black sweatshirt with a premium finish.',
        price: 1299,
        image: 'assets/images/products/sweatshirt.jpg',
      ),
      Product(
        name: 'Slim Fit Jeans',
        category: 'Jeans',
        description: 'Modern slim fit jeans for a clean everyday look.',
        price: 1399,
        image: 'assets/images/products/slimjeans.jpg',
      ),
      Product(
        name: 'Casual Trousers',
        category: 'Trousers',
        description: 'Versatile casual trousers for daily wear.',
        price: 899,
        image: 'assets/images/products/trousers.jpg',
      ),
    ];

    for (final product in products) {
      await db.insert('products', product.toMap());
    }
  }

  Future<List<Product>> getProducts() async {
    final db = await database;

    final result = await db.query(
      'products',
      orderBy: 'id DESC',
    );

    return result.map((map) => Product.fromMap(map)).toList();
  }

  Future<Product?> getProductById(int id) async {
    final db = await database;

    final result = await db.query(
      'products',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (result.isEmpty) return null;

    return Product.fromMap(result.first);
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
    _database = null;
  }
}
