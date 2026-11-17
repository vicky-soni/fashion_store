
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/product.dart';

class CartItem {
  final Product product;
  int quantity;

  CartItem({
    required this.product,
    this.quantity = 1,
  });

  double get total => product.price * quantity;

  Map<String, dynamic> toMap() {
    return {
      'product': product.toMap(),
      'quantity': quantity,
    };
  }

  factory CartItem.fromMap(Map<String, dynamic> map) {
    return CartItem(
      product: Product.fromMap(
        Map<String, dynamic>.from(map['product']),
      ),
      quantity: map['quantity'] as int,
    );
  }
}

class CartProvider extends ChangeNotifier {
  static const String _storageKey = 'fashion_store_cart';

  final Map<int, CartItem> _items = {};

  List<CartItem> get items => _items.values.toList();

  int get itemCount {
    return _items.values.fold(
      0,
      (sum, item) => sum + item.quantity,
    );
  }

  double get totalAmount {
    return _items.values.fold(
      0.0,
      (sum, item) => sum + item.total,
    );
  }

  bool get isEmpty => _items.isEmpty;

  Future<void> loadCart() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedCart = prefs.getString(_storageKey);

      if (savedCart == null) return;

      final List<dynamic> decoded = jsonDecode(savedCart);

      _items.clear();

      for (final entry in decoded) {
        final item = CartItem.fromMap(
          Map<String, dynamic>.from(entry),
        );

        final productId =
            item.product.id ?? item.product.name.hashCode;

        _items[productId] = item;
      }

      notifyListeners();
    } catch (e) {
      debugPrint('Cart loading error: $e');
    }
  }

  Future<void> addToCart(Product product) async {
    final productId = product.id ?? product.name.hashCode;

    if (_items.containsKey(productId)) {
      if (_items[productId]!.quantity < product.stock) {
        _items[productId]!.quantity++;
      }
    } else {
      if (product.stock > 0) {
        _items[productId] = CartItem(
          product: product,
          quantity: 1,
        );
      }
    }

    notifyListeners();
    await _saveCart();
  }

  Future<void> increaseQuantity(int productId) async {
    final item = _items[productId];

    if (item == null) return;

    if (item.quantity < item.product.stock) {
      item.quantity++;
      notifyListeners();
      await _saveCart();
    }
  }

  Future<void> decreaseQuantity(int productId) async {
    final item = _items[productId];

    if (item == null) return;

    if (item.quantity > 1) {
      item.quantity--;
    } else {
      _items.remove(productId);
    }

    notifyListeners();
    await _saveCart();
  }

  Future<void> removeFromCart(int productId) async {
    _items.remove(productId);

    notifyListeners();
    await _saveCart();
  }

  Future<void> clearCart() async {
    _items.clear();

    notifyListeners();
    await _saveCart();
  }

  Future<void> _saveCart() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final data = _items.values
          .map((item) => item.toMap())
          .toList();

      await prefs.setString(
        _storageKey,
        jsonEncode(data),
      );
    } catch (e) {
      debugPrint('Cart saving error: $e');
    }
  }
}
