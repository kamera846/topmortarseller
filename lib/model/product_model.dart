class ProductModel {
  const ProductModel({
    this.idProduk,
    this.idMasterProduk,
    this.namaProduk,
    this.idSatuan,
    this.idCity,
    this.hargaProduk,
    this.nameSatuan,
    this.imageProduk,
    this.stok,
    this.checkoutCount,
    this.createdAt,
    this.updatedAt,
  });

  final String? idProduk;
  final String? idMasterProduk;
  final String? namaProduk;
  final String? idSatuan;
  final String? idCity;
  final String? hargaProduk;
  final String? nameSatuan;
  final String? imageProduk;
  final int? stok;
  final String? checkoutCount;
  final String? createdAt;
  final String? updatedAt;

  ProductModel copyWith({
    String? idProduk,
    String? idMasterProduk,
    String? namaProduk,
    String? idSatuan,
    String? idCity,
    String? hargaProduk,
    String? nameSatuan,
    String? imageProduk,
    int? stok,
    String? checkoutCount,
    String? createdAt,
    String? updatedAt,
  }) {
    return ProductModel(
      idProduk: idProduk ?? this.idProduk,
      idMasterProduk: idMasterProduk ?? this.idMasterProduk,
      namaProduk: namaProduk ?? this.namaProduk,
      idSatuan: idSatuan ?? this.idSatuan,
      idCity: idCity ?? this.idCity,
      hargaProduk: hargaProduk ?? this.hargaProduk,
      nameSatuan: nameSatuan ?? this.nameSatuan,
      imageProduk: imageProduk ?? this.imageProduk,
      stok: stok ?? this.stok,
      checkoutCount: checkoutCount ?? this.checkoutCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() => {
    'id_produk': idProduk ?? '',
    'id_master_produk': idMasterProduk ?? '',
    'nama_produk': namaProduk ?? '',
    'id_satuan': idSatuan ?? '',
    'id_city': idCity ?? '',
    'harga_produk': hargaProduk ?? '',
    'name_satuan': nameSatuan ?? '',
    'image_produk': imageProduk ?? '',
    'stok': stok ?? 0,
    'created_at': createdAt ?? '',
    'updated_at': updatedAt ?? '',
  };

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      idProduk: json['id_produk'] ?? '',
      idMasterProduk: json['id_master_produk'] ?? '',
      namaProduk: json['nama_produk'] ?? '',
      idSatuan: json['id_satuan'] ?? '',
      idCity: json['id_city'] ?? '',
      hargaProduk: json['harga_produk'] ?? '',
      nameSatuan: json['name_satuan'] ?? '',
      imageProduk: json['image_produk'] ?? '',
      stok: json['stok'] ?? 0,
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
    );
  }
}
