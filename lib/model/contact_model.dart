class ContactModel {
  const ContactModel({
    this.idContact,
    this.nama = '',
    this.nomorhp,
    this.tglLahir,
    this.storeOwner,
    this.idCity,
    this.mapsUrl,
    this.address,
    this.storeStatus,
    this.ktpOwner,
    this.terminPayment,
    this.idPromo,
    this.reputation,
    this.createdAt,
    this.paymentMethod,
    this.tagihMingguan,
    this.nomorhp2,
    this.nomorCat1,
    this.nomorCat2,
    this.passContact,
    this.namaCity,
    this.kodeCity,
    this.idDistributor,
  });

  final String? idContact;
  final String? nama;
  final String? nomorhp;
  final String? tglLahir;
  final String? storeOwner;
  final String? idCity;
  final String? mapsUrl;
  final String? address;
  final String? storeStatus;
  final String? ktpOwner;
  final String? terminPayment;
  final String? idPromo;
  final String? reputation;
  final String? createdAt;
  final String? paymentMethod;
  final String? tagihMingguan;
  final String? nomorhp2;
  final String? nomorCat1;
  final String? nomorCat2;
  final String? passContact;
  final String? namaCity;
  final String? kodeCity;
  final String? idDistributor;

  factory ContactModel.fromJson(Map<String, dynamic> json) {
    return ContactModel(
      idContact: json['id_contact'] ?? '',
      nama: json['nama'] ?? '',
      nomorhp: json['nomorhp'] ?? '',
      tglLahir: json['tgl_lahir'] ?? '',
      storeOwner: json['store_owner'] ?? '',
      idCity: json['id_city'] ?? '',
      mapsUrl: json['maps_url'] ?? '',
      address: json['address'] ?? '',
      storeStatus: json['store_status'] ?? '',
      ktpOwner: json['ktp_owner'] ?? '',
      terminPayment: json['termin_payment'] ?? '',
      idPromo: json['id_promo'] ?? '',
      reputation: json['reputation'] ?? '',
      createdAt: json['created_at'] ?? '',
      paymentMethod: json['payment_method'] ?? '',
      tagihMingguan: json['tagih_mingguan'] ?? '',
      nomorhp2: json['nomorhp_2'] ?? '',
      nomorCat1: json['nomor_cat_1'] ?? '',
      nomorCat2: json['nomor_cat_2'] ?? '',
      passContact: json['pass_contact'] ?? '',
      namaCity: json['nama_city'] ?? '',
      kodeCity: json['kode_city'] ?? '',
      idDistributor: json['id_distributor'] ?? '',
    );
  }
}
