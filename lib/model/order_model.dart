import 'package:topmortarseller/model/order_item_model.dart';

class OrderModel {
  final String idAppOrder;
  final String idCart;
  final String idContact;
  final String subTotalAppOrder;
  final String discountAppOrder;
  final String totalAppOrder;
  final String statusAppOrder;
  final String totalQty;
  final String createdAt;
  final String updatedAt;
  final String deletedAt;
  final List<OrderItemModel> items;

  OrderModel({
    this.idAppOrder = '',
    this.idCart = '',
    this.idContact = '',
    this.subTotalAppOrder = '',
    this.discountAppOrder = '',
    this.totalAppOrder = '',
    this.statusAppOrder = '',
    this.totalQty = '',
    this.createdAt = '',
    this.updatedAt = '',
    this.deletedAt = '',
    this.items = const [],
  });

  OrderModel copyWith({
    String? idAppOrder,
    String? idCart,
    String? idContact,
    String? subTotalAppOrder,
    String? discountAppOrder,
    String? totalAppOrder,
    String? statusAppOrder,
    String? totalQty,
    String? createdAt,
    String? updatedAt,
    String? deletedAt,
    List<OrderItemModel>? items,
  }) {
    return OrderModel(
      idAppOrder: idAppOrder ?? this.idAppOrder,
      idCart: idCart ?? this.idCart,
      idContact: idContact ?? this.idContact,
      subTotalAppOrder: subTotalAppOrder ?? this.subTotalAppOrder,
      discountAppOrder: discountAppOrder ?? this.discountAppOrder,
      totalAppOrder: totalAppOrder ?? this.totalAppOrder,
      statusAppOrder: statusAppOrder ?? this.statusAppOrder,
      totalQty: totalQty ?? this.totalQty,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      items: items ?? this.items,
    );
  }

  Map<String, dynamic> toJson() => {
    'id_apporder': idAppOrder,
    'id_cart': idCart,
    'id_contact': idContact,
    'subtotal_apporder': subTotalAppOrder,
    'discount_apporder': discountAppOrder,
    'total_apporder': totalAppOrder,
    'status_apporder': statusAppOrder,
    'total_qty': totalQty,
    'created_at': createdAt,
    'updated_at': updatedAt,
    'deleted_at': deletedAt,
    'items': items,
  };

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      idAppOrder: json['id_apporder'] ?? '',
      idCart: json['id_cart'] ?? '',
      idContact: json['id_contact'] ?? '',
      subTotalAppOrder: json['subtotal_apporder'] ?? '',
      discountAppOrder: json['discount_apporder'] ?? '',
      totalAppOrder: json['total_apporder'] ?? '',
      statusAppOrder: json['status_apporder'] ?? '',
      totalQty: json['total_qty'] ?? '',
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
      deletedAt: json['deleted_at'] ?? '',
      items: json['items'] != null && json['items'] is List
          ? (json['items'] as List).map((item) {
              return OrderItemModel.fromJson(item);
            }).toList()
          : [],
    );
  }
}
