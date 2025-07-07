import 'package:topmortarseller/model/product_model.dart';

class CartModel {
  const CartModel({
    this.idCart,
    this.idContact,
    this.statusCart,
    this.subtotalPrice,
    this.details,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
  });

  final String? idCart;
  final String? idContact;
  final String? statusCart;
  final String? subtotalPrice;
  final List<ProductModel>? details;
  final String? createdAt;
  final String? updatedAt;
  final String? deletedAt;

  CartModel copyWith({
    String? idCart,
    String? idContact,
    String? statusCart,
    String? subtotalPrice,
    List<ProductModel>? details,
    String? createdAt,
    String? updatedAt,
    String? deletedAt,
  }) {
    return CartModel(
      idCart: idCart ?? this.idCart,
      idContact: idContact ?? this.idContact,
      statusCart: statusCart ?? this.statusCart,
      subtotalPrice: subtotalPrice ?? this.subtotalPrice,
      details: details ?? this.details,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }

  Map<String, dynamic> toJson() => {
    'id_cart': idCart ?? '',
    'id_contact': idContact ?? '',
    'status_cart': statusCart ?? '',
    'subtotal_price': subtotalPrice ?? '',
    'details': details,
    'created_at': createdAt ?? '',
    'updated_at': updatedAt ?? '',
    'deleted_at': deletedAt ?? '',
  };

  factory CartModel.fromJson(Map<String, dynamic> json) {
    return CartModel(
      idCart: json['id_cart'] ?? '',
      idContact: json['id_contact'] ?? '',
      statusCart: json['status_cart'] ?? '',
      subtotalPrice: json['subtotal_price'] ?? '',
      details: json['details'] != null && json['details'] is List
          ? (json['details'] as List)
                .map((item) => ProductModel.fromJson(item))
                .toList()
          : null,
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
      deletedAt: json['deleted_at'] ?? '',
    );
  }
}
