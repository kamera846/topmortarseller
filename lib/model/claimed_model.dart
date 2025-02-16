class ClaimedModel {
  const ClaimedModel({
    this.idVoucherTukang,
    this.idTukang,
    this.idContact,
    this.claimDate,
    this.noSeri,
    this.isClaimed,
    this.createdAt,
    this.updatedAt,
    this.expAt,
    this.idMd5,
    this.nama,
    this.nomorhp,
    this.tglLahir,
    this.idCity,
    this.mapsUrl,
    this.address,
    this.tukangStatus,
    this.ktpTukang,
    this.idSkill,
    this.namaLengkap,
  });

  final String? idVoucherTukang;
  final String? idTukang;
  final String? idContact;
  final String? claimDate;
  final String? noSeri;
  final String? isClaimed;
  final String? createdAt;
  final String? updatedAt;
  final String? expAt;
  final String? idMd5;
  final String? nama;
  final String? nomorhp;
  final String? tglLahir;
  final String? idCity;
  final String? mapsUrl;
  final String? address;
  final String? tukangStatus;
  final String? ktpTukang;
  final String? idSkill;
  final String? namaLengkap;

  Map<String, dynamic> toJson() => {
        'id_voucher_tukang': idVoucherTukang ?? '',
        'id_tukang': idTukang ?? '',
        'id_contact': idContact ?? '',
        'claim_date': claimDate ?? '',
        'no_seri': noSeri ?? '',
        'is_claimed': isClaimed ?? '',
        'created_at': createdAt ?? '',
        'updated_at': updatedAt ?? '',
        'exp_at': expAt ?? '',
        'id_md5': idMd5 ?? '',
        'nama': nama,
        'nomorhp': nomorhp ?? '',
        'tgl_lahir': tglLahir ?? '',
        'id_city': idCity ?? '',
        'maps_url': mapsUrl ?? '',
        'address': address ?? '',
        'tukang_status': tukangStatus ?? '',
        'ktp_tukang': ktpTukang ?? '',
        'id_skill': idSkill ?? '',
        'nama_lengkap': namaLengkap ?? '',
      };

  factory ClaimedModel.fromJson(Map<String, dynamic> json) {
    return ClaimedModel(
      idVoucherTukang: json['id_voucher_tukang'] ?? '',
      idTukang: json['id_tukang'] ?? '',
      idContact: json['id_contact'] ?? '',
      claimDate: json['claim_date'] ?? '',
      noSeri: json['no_seri'] ?? '',
      isClaimed: json['is_claimed'] ?? '',
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
      expAt: json['exp_at'] ?? '',
      idMd5: json['id_md5'] ?? '',
      nama: json['nama'],
      nomorhp: json['nomorhp'] ?? '',
      tglLahir: json['tgl_lahir'] ?? '',
      idCity: json['id_city'] ?? '',
      mapsUrl: json['maps_url'] ?? '',
      address: json['address'] ?? '',
      tukangStatus: json['tukang_status'] ?? '',
      ktpTukang: json['ktp_tukang'] ?? '',
      idSkill: json['id_skill'] ?? '',
      namaLengkap: json['nama_lengkap'] ?? '',
    );
  }
}
