
import 'package:sqflite/sqflite.dart';

import 'database_helper.dart';
import '../models/order.dart';

class OrderDatabase {
  OrderDatabase._();

  static final OrderDatabase instance = OrderDatabase._();

  Future<Database> get _db async {
    final db = await DatabaseHelper.instance.database;

    await db.execute('''
      CREATE TABLE IF NOT EXISTS orders (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        customer_name TEXT NOT NULL,
        mobile TEXT NOT NULL,
        address TEXT NOT NULL,
        pincode TEXT NOT NULL,
        payment_method TEXT NOT NULL,
        total_amount REAL NOT NULL,
        status TEXT NOT NULL,
        created_at TEXT NOT NULL,
        items TEXT NOT NULL
      )
    ''');

    return db;
  }

  Future<int> insertOrder(Order order) async {
    final db = await _db;

    final data = order.toMap();
    data.remove('id');

    return await db.insert(
      'orders',
      data,
      conflictAlgorithm: ConflictAlgorithm.abort,
    );
  }

  Future<List<Order>> getAllOrders() async {
    final db = await _db;

    final result = await db.query(
      'orders',
      orderBy: 'id DESC',
    );

    return result.map((map) => Order.fromMap(map)).toList();
  }

  Future<Order?> getOrderById(int id) async {
    final db = await _db;

    final result = await db.query(
      'orders',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (result.isEmpty) return null;

    return Order.fromMap(result.first);
  }

  Future<bool> cancelOrder(int id) async {
    final db = await _db;

    final result = await db.update(
      'orders',
      {'status': 'Cancelled'},
      where: 'id = ? AND status = ?',
      whereArgs: [id, 'Placed'],
    );

    return result > 0;
  }

  Future<void> deleteOrder(int id) async {
    final db = await _db;

    await db.delete(
      'orders',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
