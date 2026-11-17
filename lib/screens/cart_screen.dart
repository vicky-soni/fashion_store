
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/cart_provider.dart';
import '../utils/app_theme.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'My Shopping Cart',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: cart.isEmpty
          ? _emptyCart(context)
          : Column(
              children: [
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: cart.items.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(height: 14),
                    itemBuilder: (context, index) {
                      final item = cart.items[index];
                      final product = item.product;
                      final productId =
                          product.id ?? product.name.hashCode;

                      return _cartItem(
                        product.image,
                        product.name,
                        product.category,
                        product.price,
                        item.quantity,
                        item.total,
                        () => cart.decreaseQuantity(productId),
                        () => cart.increaseQuantity(productId),
                        () => cart.removeFromCart(productId),
                      );
                    },
                  ),
                ),
                _priceSummary(context, cart),
              ],
            ),
    );
  }

  Widget _cartItem(
    String image,
    String name,
    String category,
    double price,
    int quantity,
    double total,
    VoidCallback onDecrease,
    VoidCallback onIncrease,
    VoidCallback onRemove,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.border),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.asset(
              image,
              height: 105,
              width: 85,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) {
                return Container(
                  height: 105,
                  width: 85,
                  color: AppTheme.beige,
                  child: const Icon(
                    Icons.checkroom_outlined,
                    size: 35,
                    color: AppTheme.secondary,
                  ),
                );
              },
            ),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  category,
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  '₹${price.toStringAsFixed(0)}',
                  style: const TextStyle(
                    color: AppTheme.primary,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 9),
                Row(
                  children: [
                    _quantityButton(
                      Icons.remove,
                      onDecrease,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 13,
                      ),
                      child: Text(
                        '$quantity',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ),
                    _quantityButton(
                      Icons.add,
                      onIncrease,
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: onRemove,
                      icon: const Icon(
                        Icons.delete_outline,
                        color: Colors.redAccent,
                      ),
                      tooltip: 'Remove product',
                    ),
                  ],
                ),
                Text(
                  'Item total: ₹${total.toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _quantityButton(
    IconData icon,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(7),
      child: Container(
        height: 29,
        width: 29,
        decoration: BoxDecoration(
          color: AppTheme.beige,
          borderRadius: BorderRadius.circular(7),
          border: Border.all(color: AppTheme.border),
        ),
        child: Icon(
          icon,
          size: 17,
          color: AppTheme.primary,
        ),
      ),
    );
  }

  Widget _priceSummary(
    BuildContext context,
    CartProvider cart,
  ) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 22),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        border: Border(
          top: BorderSide(color: AppTheme.border),
        ),
      ),
      child: Column(
        children: [
          _summaryRow(
            'Total Items',
            '${cart.itemCount}',
          ),
          const SizedBox(height: 12),
          _summaryRow(
            'Subtotal',
            '₹${cart.totalAmount.toStringAsFixed(2)}',
          ),
          const SizedBox(height: 12),
          const Divider(color: AppTheme.border),
          const SizedBox(height: 8),
          _summaryRow(
            'Total Amount',
            '₹${cart.totalAmount.toStringAsFixed(2)}',
            isTotal: true,
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/checkout');
              },
              child: const Text('PROCEED TO CHECKOUT'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryRow(
    String title,
    String value, {
    bool isTotal = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            color: isTotal
                ? AppTheme.textPrimary
                : AppTheme.textSecondary,
            fontWeight:
                isTotal ? FontWeight.bold : FontWeight.normal,
            fontSize: isTotal ? 17 : 14,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: isTotal
                ? AppTheme.primary
                : AppTheme.textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: isTotal ? 19 : 14,
          ),
        ),
      ],
    );
  }

  Widget _emptyCart(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(25),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.shopping_bag_outlined,
              size: 85,
              color: AppTheme.secondary,
            ),
            const SizedBox(height: 20),
            const Text(
              'Your Cart is Empty',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Looks like you have not added anything yet.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 22),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('CONTINUE SHOPPING'),
            ),
          ],
        ),
      ),
    );
  }
}
