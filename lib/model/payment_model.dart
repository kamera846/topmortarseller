class PaymentModel {
  final String idPayment;
  final String amountPayment;
  final String datePayment;
  final String remarkPayment;
  final String idInvoice;
  final String isRemoved;
  final String potonganPayment;
  final String adjustmentPayment;
  final String source;

  PaymentModel({
    this.idPayment = '',
    this.amountPayment = '',
    this.datePayment = '',
    this.remarkPayment = '',
    this.idInvoice = '',
    this.isRemoved = '',
    this.potonganPayment = '',
    this.adjustmentPayment = '',
    this.source = '',
  });

  factory PaymentModel.fromJson(Map<String, dynamic> json) {
    return PaymentModel(
      idPayment: json['id_payment'] ?? '',
      amountPayment: json['amount_payment'] ?? '',
      datePayment: json['date_payment'] ?? '',
      remarkPayment: json['remark_payment'] ?? '',
      idInvoice: json['id_invoice'] ?? '',
      isRemoved: json['is_removed'] ?? '',
      potonganPayment: json['potongan_payment'] ?? '',
      adjustmentPayment: json['adjustment_payment'] ?? '',
      source: json['source'] ?? '',
    );
  }
}
