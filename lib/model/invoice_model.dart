import 'package:topmortarseller/model/invoice_item_model.dart';

class InvoiceModel {
  final String idInvoice;
  final String noInvoie;
  final String billToName;
  final String billToPhone;
  final String billToAddress;
  final String subTotalInvoice;
  final String discountAppOrder;
  final String totalInvoice;
  final String statusInvoice;
  final String dateInvoice;
  final String createdAt;
  final String updatedAt;
  final String deletedAt;
  final List<InvoiceItemModel> item;

  InvoiceModel({
    required this.idInvoice,
    required this.noInvoie,
    required this.billToName,
    required this.billToPhone,
    required this.billToAddress,
    required this.subTotalInvoice,
    required this.discountAppOrder,
    required this.totalInvoice,
    required this.statusInvoice,
    required this.dateInvoice,
    required this.createdAt,
    required this.updatedAt,
    required this.deletedAt,
    required this.item,
  });

  InvoiceModel copyWith({
    String? idInvoice,
    String? noInvoie,
    String? billToName,
    String? billToPhone,
    String? billToAddress,
    String? subTotalInvoice,
    String? discountAppOrder,
    String? totalInvoice,
    String? statusInvoice,
    String? totalQty,
    String? dateInvoice,
    String? createdAt,
    String? updatedAt,
    String? deletedAt,
    List<InvoiceItemModel>? item,
  }) {
    return InvoiceModel(
      idInvoice: idInvoice ?? this.idInvoice,
      noInvoie: noInvoie ?? this.noInvoie,
      billToName: billToName ?? this.billToName,
      billToPhone: billToPhone ?? this.billToPhone,
      billToAddress: billToAddress ?? this.billToAddress,
      subTotalInvoice: subTotalInvoice ?? this.subTotalInvoice,
      discountAppOrder: discountAppOrder ?? this.discountAppOrder,
      totalInvoice: totalInvoice ?? this.totalInvoice,
      statusInvoice: statusInvoice ?? this.statusInvoice,
      dateInvoice: dateInvoice ?? this.dateInvoice,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      item: item ?? this.item,
    );
  }

  Map<String, dynamic> toJson() => {
    'id_invoice': idInvoice,
    'no_invoice': noInvoie,
    'bill_to_name': billToName,
    'bill_to_phone': billToPhone,
    'bill_to_address': billToAddress,
    'subtotal_invoice': subTotalInvoice,
    'discount_apporder': discountAppOrder,
    'total_invoice': totalInvoice,
    'status_invoice': statusInvoice,
    'date_invoice': dateInvoice,
    'created_at': createdAt,
    'updated_at': updatedAt,
    'deleted_at': deletedAt,
    'item': item,
  };

  factory InvoiceModel.fromJson(Map<String, dynamic> json) {
    return InvoiceModel(
      idInvoice: json['id_invoice'] ?? '',
      noInvoie: json['no_invoice'] ?? '',
      billToName: json['bill_to_name'] ?? '',
      billToPhone: json['bill_to_phone'] ?? '',
      billToAddress: json['bill_to_address'] ?? '',
      subTotalInvoice: json['subtotal_invoice'] ?? '',
      discountAppOrder: json['discount_apporder'] ?? '',
      totalInvoice: json['total_invoice'] ?? '',
      statusInvoice: json['status_invoice'] ?? '',
      dateInvoice: json['date_invoice'] ?? '',
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
