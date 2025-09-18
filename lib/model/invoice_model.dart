import 'package:topmortarseller/model/discount_extra_model.dart';
import 'package:topmortarseller/model/invoice_item_model.dart';
import 'package:topmortarseller/model/payment_model.dart';

class InvoiceModel {
  final String idInvoice;
  final String noInvoie;
  final String billToName;
  final String billToPhone;
  final String billToAddress;
  final String subTotalInvoice;
  final String discountAppInvoice;
  final String? discountExtraName;
  final String discountExtraAmount;
  final String totalInvoice;
  final String statusInvoice;
  final String dateInvoice;
  final String dateJatem;
  final String totalQty;
  final String createdAt;
  final String updatedAt;
  final String deletedAt;
  final List<InvoiceItemModel> item;
  final DiscountExtra? discountExtra;
  final String totalPayment;
  final String sisaInvoice;
  final List<PaymentModel> payments;

  InvoiceModel({
    this.idInvoice = '',
    this.noInvoie = '',
    this.billToName = '',
    this.billToPhone = '',
    this.billToAddress = '',
    this.subTotalInvoice = '',
    this.discountAppInvoice = '',
    this.discountExtraName,
    this.discountExtraAmount = '',
    this.totalInvoice = '',
    this.statusInvoice = '',
    this.dateInvoice = '',
    this.dateJatem = '',
    this.totalQty = '',
    this.createdAt = '',
    this.updatedAt = '',
    this.deletedAt = '',
    this.item = const [],
    this.discountExtra,
    this.totalPayment = '0',
    this.sisaInvoice = '0',
    this.payments = const [],
  });

  InvoiceModel copyWith({
    String? idInvoice,
    String? noInvoie,
    String? billToName,
    String? billToPhone,
    String? billToAddress,
    String? subTotalInvoice,
    String? discountAppInvoice,
    String? discountExtraName,
    String? discountExtraAmount,
    String? totalInvoice,
    String? statusInvoice,
    String? totalQty,
    String? dateInvoice,
    String? dateJatem,
    String? createdAt,
    String? updatedAt,
    String? deletedAt,
    List<InvoiceItemModel>? item,
    DiscountExtra? discountExtra,
    String? totalPayment,
    String? sisaInvoice,
    List<PaymentModel>? payments,
  }) {
    return InvoiceModel(
      idInvoice: idInvoice ?? this.idInvoice,
      noInvoie: noInvoie ?? this.noInvoie,
      billToName: billToName ?? this.billToName,
      billToPhone: billToPhone ?? this.billToPhone,
      billToAddress: billToAddress ?? this.billToAddress,
      subTotalInvoice: subTotalInvoice ?? this.subTotalInvoice,
      discountAppInvoice: discountAppInvoice ?? this.discountAppInvoice,
      discountExtraName: discountExtraName ?? this.discountExtraName,
      discountExtraAmount: discountExtraAmount ?? this.discountExtraAmount,
      totalInvoice: totalInvoice ?? this.totalInvoice,
      statusInvoice: statusInvoice ?? this.statusInvoice,
      dateInvoice: dateInvoice ?? this.dateInvoice,
      dateJatem: dateJatem ?? this.dateJatem,
      totalQty: totalQty ?? this.totalQty,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      item: item ?? this.item,
      discountExtra: discountExtra ?? this.discountExtra,
      totalPayment: totalPayment ?? this.totalPayment,
      sisaInvoice: sisaInvoice ?? this.sisaInvoice,
      payments: payments ?? this.payments,
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
    'discount_extra_name': discountExtraName,
    'discount_extra_amount': discountExtraAmount,
    'total_invoice': totalInvoice,
    'status_invoice': statusInvoice,
    'date_invoice': dateInvoice,
    'date_jatem': dateJatem,
    'total_qty': totalQty,
    'created_at': createdAt,
    'updated_at': updatedAt,
    'deleted_at': deletedAt,
    'item': item,
    'discount_extra': discountExtra,
    'totalPayment': totalPayment,
    'sisaInvoice': sisaInvoice,
    'payment': payments,
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
      discountExtraName: json['discount_extra_name'],
      discountExtraAmount: json['discount_extra_amount'] ?? '0',
      totalInvoice: json['total_invoice'] ?? '',
      statusInvoice: json['status_invoice'] ?? '',
      dateInvoice: json['date_invoice'] ?? '',
      dateJatem: json['date_jatem'] ?? '',
      totalQty: json['total_qty'] ?? '',
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
      deletedAt: json['deleted_at'] ?? '',
      item: json['item'] != null && json['item'] is List
          ? (json['item'] as List).map((item) {
              return InvoiceItemModel.fromJson(item);
            }).toList()
          : [],
      discountExtra: json['discount_extra'] != null
          ? DiscountExtra.fromJson(json['discount_extra'])
          : null,
      totalPayment: json['totalPayment'] ?? '0',
      sisaInvoice: json['sisaInvoice'] ?? '0',
      payments: json['payment'] != null && json['payment'] is List
          ? (json['payment'] as List)
                .map((e) => PaymentModel.fromJson(e))
                .toList()
          : [],
    );
  }
}
