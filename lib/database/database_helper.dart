
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;
import '../models/product.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();

  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;

    final dbPath = await getDatabasesPath();
    final path = p.join(dbPath, 'fashion_store.db');

    _database = await openDatabase(
      path,
      version: 1,
      onCreate: _createDatabase,
    );

    return _database!;
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
        stock INTEGER NOT NULL DEFAULT 20,
        is_new INTEGER NOT NULL DEFAULT 0
      )
    ''');

    final sampleProducts = [
      Product(
        name: 'Oversized T-Shirt',
        category: 'T-Shirts',
        description: 'Premium cotton oversized t-shirt.',
        price: 599,
        image: 'assets/images/products/tshirt.jpg',
        isNew: true,
      ),
      Product(
        name: 'Classic Denim Jeans',
        category: 'Jeans',
        description: 'Classic blue denim jeans.',
        price: 1199,
        image: 'assets/images/products/jeans.jpg',
      ),
      Product(
        name: 'Casual White Shirt',
        category: 'Shirts',
        description: 'Elegant casual white shirt.',
        price: 899,
        image: 'assets/images/products/shirt.jpg',
        isNew: true,
      ),
      Product(
        name: 'Classic Hoodie',
        category: 'Hoodies',
        description: 'Soft and comfortable hoodie.',
        price: 1499,
        image: 'assets/images/products/hoodie.jpg',
      ),
      Product(
        name: 'Cotton Polo T-Shirt',
        category: 'T-Shirts',
        description: 'Classic cotton polo t-shirt.',
        price: 749,
        image: 'assets/images/products/polo.jpg',
      ),
      Product(
        name: 'Cargo Pants',
        category: 'Trousers',
        description: 'Modern cargo pants.',
        price: 999,
        image: 'assets/images/products/cargo.jpg',
      ),
      Product(
        name: 'Formal Shirt',
        category: 'Shirts',
        description: 'Premium formal shirt.',
        price: 1099,
        image: 'assets/images/products/formal.jpg',
      ),
      Product(
        name: 'Black Sweatshirt',
        category: 'Hoodies',
        description: 'Minimal black sweatshirt.',
        price: 1299,
        image: 'assets/images/products/sweatshirt.jpg',
      ),
      Product(
        name: 'Slim Fit Jeans',
        category: 'Jeans',
        description: 'Comfortable slim fit jeans.',
        price: 1399,
        image: 'assets/images/products/slimjeans.jpg',
      ),
      Product(
        name: 'Casual Trousers',
        category: 'Trousers',
        description: 'Everyday casual trousers.',
        price: 899,
        image: 'assets/images/products/trousers.jpg',
      ),
    ];

    for (final product in sampleProducts) {
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

  Future<void> close() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }
}
