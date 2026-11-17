
import 'package:flutter/foundation.dart';

import '../database/order_database.dart';
import '../models/order.dart';
import '../providers/cart_provider.dart';

class OrderProvider extends ChangeNotifier {
  final OrderDatabase _database = OrderDatabase.instance;

  List<Order> _orders = [];
  bool _isLoading = false;
  String? _error;

  List<Order> get orders => _orders;

  bool get isLoading => _isLoading;

  String? get error => _error;

  Future<void> loadOrders() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _orders = await _database.getAllOrders();
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> placeOrder({
    required String customerName,
    required String mobile,
    required String address,
    required String pincode,
    required String paymentMethod,
    required CartProvider cart,
  }) async {
    if (cart.isEmpty) {
      _error = 'Your cart is empty.';
      notifyListeners();
      return false;
    }

    try {
      _error = null;

      final orderItems = cart.items.map((item) {
        return OrderItem(
          productId: item.product.id ?? 0,
          productName: item.product.name,
          image: item.product.image,
          price: item.product.price,
          quantity: item.quantity,
        );
      }).toList();

      final order = Order(
        customerName: customerName,
        mobile: mobile,
        address: address,
        pincode: pincode,
        paymentMethod: paymentMethod,
        totalAmount: cart.totalAmount,
        status: 'Placed',
        createdAt: DateTime.now(),
        items: orderItems,
      );

      await _database.insertOrder(order);

      await cart.clearCart();

      await loadOrders();

      return true;
    } catch (e) {
      _error = 'Unable to place order: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> cancelOrder(int orderId) async {
    try {
      final cancelled = await _database.cancelOrder(orderId);

      if (cancelled) {
        await loadOrders();
      }

      return cancelled;
    } catch (e) {
      _error = 'Unable to cancel order: $e';
      notifyListeners();
      return false;
    }
  }

  Future<Order?> getOrderDetails(int id) async {
    try {
      return await _database.getOrderById(id);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return null;
    }
  }
}
