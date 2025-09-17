class QrisModel {
  final String idQrisPayment;
  final String idApporder;
  final String idInvoice;
  final String amountQrisPayment;
  final String imgQrisPayment;
  final String contentQrisPayment;
  final String dateQrisPayment;
  final String invQrisPayment;
  final String nmidQrisPayment;
  final String statusQrisPayment;
  final String? paidAt;
  final String? customerQrisPayment;
  final String? methodQrisPayment;
  final String? versionQrisPayment;
  final String createdAt;
  final String updatedAt;

  const QrisModel({
    this.idQrisPayment = "",
    this.idApporder = "",
    this.idInvoice = "",
    this.amountQrisPayment = "",
    this.imgQrisPayment = "",
    this.contentQrisPayment = "",
    this.dateQrisPayment = "",
    this.invQrisPayment = "",
    this.nmidQrisPayment = "",
    this.statusQrisPayment = "",
    this.paidAt,
    this.customerQrisPayment,
    this.methodQrisPayment,
    this.versionQrisPayment,
    this.createdAt = "",
    this.updatedAt = "",
  });

  factory QrisModel.fromJson(Map<String, dynamic> json) {
    return QrisModel(
      idQrisPayment: json['id_qris_payment'] ?? '',
      idApporder: json['id_apporder'] ?? '',
      idInvoice: json['id_invoice'] ?? '',
      amountQrisPayment: json['amount_qris_payment'] ?? '',
      imgQrisPayment: json['img_qris_payment'] ?? '',
      contentQrisPayment: json['content_qris_payment'] ?? '',
      dateQrisPayment: json['date_qris_payment'] ?? '',
      invQrisPayment: json['inv_qris_payment'] ?? '',
      nmidQrisPayment: json['nmid_qris_payment'] ?? '',
      statusQrisPayment: json['status_qris_payment'] ?? '',
      paidAt: json['paid_at'],
      customerQrisPayment: json['customer_qris_payment'],
      methodQrisPayment: json['method_qris_payment'],
      versionQrisPayment: json['version_qris_payment'],
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
    );
  }
}
