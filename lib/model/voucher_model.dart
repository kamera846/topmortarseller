class VoucherModel {
  final String idVoucher;
  final String idContact;
  final String noVoucher;
  final String noFisik;
  final String pointVoucher;
  final String valueVoucher;
  final String dateVoucher;
  final String isClaimed;
  final String expDate;
  final String typeVoucher;
  bool isSelected;

  VoucherModel({
    this.idVoucher = "",
    this.idContact = "",
    this.noVoucher = "",
    this.noFisik = "",
    this.pointVoucher = "",
    this.valueVoucher = "",
    this.dateVoucher = "",
    this.isClaimed = "",
    this.expDate = "",
    this.typeVoucher = "",
    this.isSelected = false,
  });

  factory VoucherModel.fromJson(Map<String, dynamic> json) {
    return VoucherModel(
      idVoucher: json["id_voucher"] ?? "",
      idContact: json["id_contact"] ?? "",
      noVoucher: json["no_voucher"] ?? "",
      noFisik: json["no_fisik"] ?? "",
      pointVoucher: json["point_voucher"] ?? "",
      valueVoucher: json["value_voucher"] ?? "",
      dateVoucher: json["date_voucher"] ?? "",
      isClaimed: json["is_claimed"] ?? "",
      expDate: json["exp_date"] ?? "",
      typeVoucher: json["type_voucher"] ?? "",
      isSelected: false,
    );
  }
}
