
import 'dart:convert';

class OrderItem {
  final int productId;
  final String productName;
  final String image;
  final double price;
  final int quantity;

  const OrderItem({
    required this.productId,
    required this.productName,
    required this.image,
    required this.price,
    required this.quantity,
  });

  double get total => price * quantity;

  Map<String, dynamic> toMap() {
    return {
      'product_id': productId,
      'product_name': productName,
      'image': image,
      'price': price,
      'quantity': quantity,
    };
  }

  factory OrderItem.fromMap(Map<String, dynamic> map) {
    return OrderItem(
      productId: map['product_id'] as int,
      productName: map['product_name'] as String,
      image: map['image'] as String,
      price: (map['price'] as num).toDouble(),
      quantity: map['quantity'] as int,
    );
  }
}

class Order {
  final int? id;
  final String customerName;
  final String mobile;
  final String address;
  final String pincode;
  final String paymentMethod;
  final double totalAmount;
  final String status;
  final DateTime createdAt;
  final List<OrderItem> items;

  const Order({
    this.id,
    required this.customerName,
    required this.mobile,
    required this.address,
    required this.pincode,
    required this.paymentMethod,
    required this.totalAmount,
    this.status = 'Placed',
    required this.createdAt,
    required this.items,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'customer_name': customerName,
      'mobile': mobile,
      'address': address,
      'pincode': pincode,
      'payment_method': paymentMethod,
      'total_amount': totalAmount,
      'status': status,
      'created_at': createdAt.toIso8601String(),
      'items': jsonEncode(
        items.map((item) => item.toMap()).toList(),
      ),
    };
  }

  factory Order.fromMap(Map<String, dynamic> map) {
    final decodedItems = jsonDecode(map['items'] as String)
        as List<dynamic>;

    return Order(
      id: map['id'] as int?,
      customerName: map['customer_name'] as String,
      mobile: map['mobile'] as String,
      address: map['address'] as String,
      pincode: map['pincode'] as String,
      paymentMethod: map['payment_method'] as String,
      totalAmount: (map['total_amount'] as num).toDouble(),
      status: map['status'] as String,
      createdAt: DateTime.parse(map['created_at'] as String),
      items: decodedItems.map((item) {
        return OrderItem.fromMap(
          Map<String, dynamic>.from(item),
        );
      }).toList(),
    );
  }

  Order copyWith({
    int? id,
    String? status,
  }) {
    return Order(
      id: id ?? this.id,
      customerName: customerName,
      mobile: mobile,
      address: address,
      pincode: pincode,
      paymentMethod: paymentMethod,
      totalAmount: totalAmount,
      status: status ?? this.status,
      createdAt: createdAt,
      items: items,
    );
  }
}
