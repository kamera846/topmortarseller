class BankModel {
  const BankModel({
    this.idBank,
    this.namaBank,
    this.swiftBank,
    this.isBca,
  });

  final String? idBank;
  final String? namaBank;
  final String? swiftBank;
  final String? isBca;

  Map<String, dynamic> toJson() => {
        'id_bank': idBank ?? '',
        'nama_bank': namaBank ?? '',
        'swift_bank': swiftBank ?? '',
        'is_bca': isBca ?? '',
      };

  factory BankModel.fromJson(Map<String, dynamic> json) {
    return BankModel(
      idBank: json['id_bank'] ?? '',
      namaBank: json['nama_bank'] ?? '',
      swiftBank: json['swift_bank'] ?? '',
      isBca: json['is_bca'] ?? '',
    );
  }
}
