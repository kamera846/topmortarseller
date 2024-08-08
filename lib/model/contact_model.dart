class ContactModel {
  const ContactModel({
    this.id_contact,
    this.nama = '',
    this.nomorhp,
    this.tgl_lahir,
    this.store_owner,
    this.id_city,
    this.maps_url,
    this.address,
    this.store_status,
    this.ktp_owner,
    this.termin_payment,
    this.id_promo,
    this.reputation,
    this.created_at,
    this.payment_method,
    this.tagih_mingguan,
    this.nomorhp_2,
    this.nomor_cat_1,
    this.nomor_cat_2,
    this.pass_contact,
    this.nama_city,
    this.kode_city,
    this.id_distributor,
  });

  final String? id_contact;
  final String? nama;
  final String? nomorhp;
  final String? tgl_lahir;
  final String? store_owner;
  final String? id_city;
  final String? maps_url;
  final String? address;
  final String? store_status;
  final String? ktp_owner;
  final String? termin_payment;
  final String? id_promo;
  final String? reputation;
  final String? created_at;
  final String? payment_method;
  final String? tagih_mingguan;
  final String? nomorhp_2;
  final String? nomor_cat_1;
  final String? nomor_cat_2;
  final String? pass_contact;
  final String? nama_city;
  final String? kode_city;
  final String? id_distributor;

  factory ContactModel.fromJson(Map<String, dynamic> json) {
    return ContactModel(
      id_contact: json['id_contact'] ?? '',
      nama: json['nama'] ?? '',
      nomorhp: json['nomorhp'] ?? '',
      tgl_lahir: json['tgl_lahir'] ?? '',
      store_owner: json['store_owner'] ?? '',
      id_city: json['id_city'] ?? '',
      maps_url: json['maps_url'] ?? '',
      address: json['address'] ?? '',
      store_status: json['store_status'] ?? '',
      ktp_owner: json['ktp_owner'] ?? '',
      termin_payment: json['termin_payment'] ?? '',
      id_promo: json['id_promo'] ?? '',
      reputation: json['reputation'] ?? '',
      created_at: json['created_at'] ?? '',
      payment_method: json['payment_method'] ?? '',
      tagih_mingguan: json['tagih_mingguan'] ?? '',
      nomorhp_2: json['nomorhp_2'] ?? '',
      nomor_cat_1: json['nomor_cat_1'] ?? '',
      nomor_cat_2: json['nomor_cat_2'] ?? '',
      pass_contact: json['pass_contact'] ?? '',
      nama_city: json['nama_city'] ?? '',
      kode_city: json['kode_city'] ?? '',
      id_distributor: json['id_distributor'] ?? '',
    );
  }
}
