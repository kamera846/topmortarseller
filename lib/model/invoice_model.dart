import 'package:topmortarseller/model/invoice_item_model.dart';

class InvoiceModel {
  final String idInvoice;
  final String noInvoie;
  final String billToName;
  final String billToPhone;
  final String billToAddress;
  final String subTotalInvoice;
  final String discountAppInvoice;
  final String totalInvoice;
  final String statusInvoice;
  final String dateInvoice;
  final String totalQty;
  final String createdAt;
  final String updatedAt;
  final String deletedAt;
  final List<InvoiceItemModel> item;

  InvoiceModel({
    this.idInvoice = '',
    this.noInvoie = '',
    this.billToName = '',
    this.billToPhone = '',
    this.billToAddress = '',
    this.subTotalInvoice = '',
    this.discountAppInvoice = '',
    this.totalInvoice = '',
    this.statusInvoice = '',
    this.dateInvoice = '',
    this.totalQty = '',
    this.createdAt = '',
    this.updatedAt = '',
    this.deletedAt = '',
    this.item = const [],
  });

  InvoiceModel copyWith({
    String? idInvoice,
    String? noInvoie,
    String? billToName,
    String? billToPhone,
    String? billToAddress,
    String? subTotalInvoice,
    String? discountAppInvoice,
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
      discountAppInvoice: discountAppInvoice ?? this.discountAppInvoice,
      totalInvoice: totalInvoice ?? this.totalInvoice,
      statusInvoice: statusInvoice ?? this.statusInvoice,
      dateInvoice: dateInvoice ?? this.dateInvoice,
      totalQty: totalQty ?? this.totalQty,
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
    'discount_app_invoice': discountAppInvoice,
    'total_invoice': totalInvoice,
    'status_invoice': statusInvoice,
    'date_invoice': dateInvoice,
    'total_qty': totalQty,
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
      discountAppInvoice: json['discount_app_invoice'] ?? '',
      totalInvoice: json['total_invoice'] ?? '',
      statusInvoice: json['status_invoice'] ?? '',
      dateInvoice: json['date_invoice'] ?? '',
      totalQty: json['total_qty'] ?? '',
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
