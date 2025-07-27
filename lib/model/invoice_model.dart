import 'package:topmortarseller/model/invoice_item_model.dart';

class InvoiceModel {
  final String idInvoice; //
  final String noInvoie; //
  final String subTotalInvoice; //
  final String discountAppOrder;
  final String totalInvoice; //
  final String statusInvoice; //
  final String createdAt; //
  final String updatedAt; //
  final String deletedAt; //
  final List<InvoiceItemModel> item; //

  InvoiceModel({
    required this.idInvoice,
    required this.noInvoie,
    required this.subTotalInvoice,
    required this.discountAppOrder,
    required this.totalInvoice,
    required this.statusInvoice,
    required this.createdAt,
    required this.updatedAt,
    required this.deletedAt,
    required this.item,
  });

  InvoiceModel copyWith({
    String? idInvoice,
    String? noInvoie,
    String? idContact,
    String? subTotalInvoice,
    String? discountAppOrder,
    String? totalInvoice,
    String? statusInvoice,
    String? totalQty,
    String? createdAt,
    String? updatedAt,
    String? deletedAt,
    List<InvoiceItemModel>? item,
  }) {
    return InvoiceModel(
      idInvoice: idInvoice ?? this.idInvoice,
      noInvoie: noInvoie ?? this.noInvoie,
      subTotalInvoice: subTotalInvoice ?? this.subTotalInvoice,
      discountAppOrder: discountAppOrder ?? this.discountAppOrder,
      totalInvoice: totalInvoice ?? this.totalInvoice,
      statusInvoice: statusInvoice ?? this.statusInvoice,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      item: item ?? this.item,
    );
  }

  Map<String, dynamic> toJson() => {
    'id_invoice': idInvoice,
    'no_invoice': noInvoie,
    'subtotal_invoice': subTotalInvoice,
    'discount_apporder': discountAppOrder,
    'total_invoice': totalInvoice,
    'status_invoice': statusInvoice,
    'created_at': createdAt,
    'updated_at': updatedAt,
    'deleted_at': deletedAt,
    'item': item,
  };

  factory InvoiceModel.fromJson(Map<String, dynamic> json) {
    return InvoiceModel(
      idInvoice: json['id_invoice'] ?? '',
      noInvoie: json['no_invoice'] ?? '',
      subTotalInvoice: json['subtotal_invoice'] ?? '',
      discountAppOrder: json['discount_apporder'] ?? '',
      totalInvoice: json['total_invoice'] ?? '',
      statusInvoice: json['status_invoice'] ?? '',
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
      deletedAt: json['deleted_at'] ?? '',
      item: json['item'] != null && json['item'] is List
          ? (json['item'] as List)
                .map((e) => InvoiceItemModel.fromJson(e))
                .toList()
          : [],
    );
  }
}
