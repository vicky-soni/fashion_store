
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/cart_provider.dart';
import '../providers/order_provider.dart';
import '../utils/app_theme.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _mobileController = TextEditingController();
  final _addressController = TextEditingController();
  final _pincodeController = TextEditingController();

  String paymentMethod = 'Cash on Delivery';
  bool isPlacingOrder = false;

  @override
  void dispose() {
    _nameController.dispose();
    _mobileController.dispose();
    _addressController.dispose();
    _pincodeController.dispose();
    super.dispose();
  }

  Future<void> _placeOrder() async {
    if (!_formKey.currentState!.validate()) return;

    final cart = context.read<CartProvider>();
    final orderProvider = context.read<OrderProvider>();

    if (cart.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Your cart is empty.')),
      );
      return;
    }

    setState(() => isPlacingOrder = true);

    final success = await orderProvider.placeOrder(
      customerName: _nameController.text.trim(),
      mobile: _mobileController.text.trim(),
      address: _addressController.text.trim(),
      pincode: _pincodeController.text.trim(),
      paymentMethod: paymentMethod,
      cart: cart,
    );

    if (!mounted) return;

    setState(() => isPlacingOrder = false);

    if (success) {
      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) {
          return AlertDialog(
            backgroundColor: AppTheme.surface,
            icon: const Icon(
              Icons.check_circle,
              color: AppTheme.success,
              size: 65,
            ),
            title: const Text('Order Placed Successfully!'),
            content: const Text(
              'Thank you for shopping with Fashion Store. '
              'Your order has been saved successfully.',
              textAlign: TextAlign.center,
            ),
            actions: [
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(dialogContext);
                    Navigator.pop(context);
                  },
                  child: const Text('CONTINUE SHOPPING'),
                ),
              ),
            ],
          );
        },
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            orderProvider.error ?? 'Something went wrong.',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Checkout',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: cart.isEmpty
          ? const Center(child: Text('Your cart is empty.'))
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(18),
                children: [
                  _sectionTitle('Delivery Information'),
                  const SizedBox(height: 15),

                  _inputField(
                    controller: _nameController,
                    label: 'Full Name',
                    icon: Icons.person_outline,
                    validator: (value) {
                      if (value == null || value.trim().length < 3) {
                        return 'Enter a valid full name';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 15),

                  _inputField(
                    controller: _mobileController,
                    label: 'Mobile Number',
                    icon: Icons.phone_outlined,
                    keyboardType: TextInputType.phone,
                    maxLength: 10,
                    validator: (value) {
                      if (value == null ||
                          !RegExp(r'^[6-9][0-9]{9}$')
                              .hasMatch(value.trim())) {
                        return 'Enter a valid 10-digit mobile number';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 15),

                  _inputField(
                    controller: _addressController,
                    label: 'Full Delivery Address',
                    icon: Icons.location_on_outlined,
                    maxLines: 3,
                    validator: (value) {
                      if (value == null || value.trim().length < 10) {
                        return 'Enter a complete delivery address';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 15),

                  _inputField(
                    controller: _pincodeController,
                    label: 'PIN Code',
                    icon: Icons.markunread_mailbox_outlined,
                    keyboardType: TextInputType.number,
                    maxLength: 6,
                    validator: (value) {
                      if (value == null ||
                          !RegExp(r'^[1-9][0-9]{5}$')
                              .hasMatch(value.trim())) {
                        return 'Enter a valid 6-digit PIN code';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 28),

                  _sectionTitle('Payment Method'),
                  const SizedBox(height: 12),

                  _paymentOption(
                    title: 'Cash on Delivery',
                    subtitle: 'Pay when your order arrives',
                    icon: Icons.payments_outlined,
                  ),

                  _paymentOption(
                    title: 'UPI',
                    subtitle: 'Demo UPI payment',
                    icon: Icons.account_balance_wallet_outlined,
                  ),

                  _paymentOption(
                    title: 'Debit / Credit Card',
                    subtitle: 'Demo card payment',
                    icon: Icons.credit_card_outlined,
                  ),

                  const SizedBox(height: 25),

                  _sectionTitle('Order Summary'),
                  const SizedBox(height: 12),

                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.surface,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppTheme.border),
                    ),
                    child: Column(
                      children: [
                        _summaryRow(
                          'Total Products',
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
                          'Grand Total',
                          '₹${cart.totalAmount.toStringAsFixed(2)}',
                          isTotal: true,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 25),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed:
                          isPlacingOrder ? null : _placeOrder,
                      child: Padding(
                        padding: const EdgeInsets.all(5),
                        child: isPlacingOrder
                            ? const SizedBox(
                                height: 22,
                                width: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.black,
                                ),
                              )
                            : const Text('PLACE ORDER'),
                      ),
                    ),
                  ),

                  const SizedBox(height: 15),

                  const Text(
                    'Note: All payment options are simulated '
                    'for this academic project. No real payment '
                    'will be processed.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 11,
                    ),
                  ),

                  const SizedBox(height: 25),
                ],
              ),
            ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 19,
        fontWeight: FontWeight.bold,
        color: AppTheme.textPrimary,
      ),
    );
  }

  Widget _inputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    int? maxLength,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      maxLength: maxLength,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        counterText: '',
      ),
    );
  }

  Widget _paymentOption({
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    final selected = paymentMethod == title;

    return InkWell(
      onTap: () {
        setState(() {
          paymentMethod = title;
        });
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: selected
              ? AppTheme.beige
              : AppTheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected
                ? AppTheme.primary
                : AppTheme.border,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: AppTheme.primary,
              size: 25,
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              selected
                  ? Icons.radio_button_checked
                  : Icons.radio_button_off,
              color: selected
                  ? AppTheme.primary
                  : AppTheme.textSecondary,
            ),
          ],
        ),
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
            fontSize: isTotal ? 16 : 14,
            fontWeight:
                isTotal ? FontWeight.bold : FontWeight.normal,
            color: isTotal
                ? AppTheme.textPrimary
                : AppTheme.textSecondary,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isTotal ? 19 : 14,
            fontWeight: FontWeight.bold,
            color: isTotal
                ? AppTheme.primary
                : AppTheme.textPrimary,
          ),
        ),
      ],
    );
  }
}
