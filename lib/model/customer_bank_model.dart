class CustomerBankModel {
  const CustomerBankModel({
    this.idRekeningToko,
    this.idContact,
    this.toName,
    this.idBank,
    this.toAccount,
    this.createdAt,
    this.updatedAt,
    this.namaBank,
    this.swiftBank,
    this.isBca,
  });

  final String? idRekeningToko;
  final String? idContact;
  final String? toName;
  final String? idBank;
  final String? toAccount;
  final String? createdAt;
  final String? updatedAt;
  final String? namaBank;
  final String? swiftBank;
  final String? isBca;

  Map<String, dynamic> toJson() => {
        'id_rekening_toko': idRekeningToko ?? '',
        'id_contact': idContact ?? '',
        'to_name': toName ?? '',
        'id_bank': idBank ?? '',
        'to_account': toAccount ?? '',
        'created_at': createdAt ?? '',
        'updated_at': updatedAt ?? '',
        'nama_bank': namaBank ?? '',
        'swift_bank': swiftBank ?? '',
        'is_bca': isBca ?? '',
      };

  factory CustomerBankModel.fromJson(Map<String, dynamic> json) {
    return CustomerBankModel(
      idRekeningToko: json['id_rekening_toko'] ?? '',
      idContact: json['id_contact'] ?? '',
      toName: json['to_name'] ?? '',
      idBank: json['id_bank'] ?? '',
      toAccount: json['to_account'] ?? '',
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
      namaBank: json['nama_bank'] ?? '',
      swiftBank: json['swift_bank'] ?? '',
      isBca: json['is_bca'] ?? '',
    );
  }
}
