class ProductModel {
  const ProductModel({
    this.idCartDetail,
    this.idCart,
    this.qtyCartDetail,
    this.idProduk,
    this.idMasterProduk,
    this.namaProduk,
    this.idSatuan,
    this.idCity,
    this.hargaProduk,
    this.nameSatuan,
    this.imageProduk,
    this.createdAt,
    this.updatedAt,
  });

  final String? idCartDetail;
  final String? idCart;
  final String? qtyCartDetail;
  final String? idProduk;
  final String? idMasterProduk;
  final String? namaProduk;
  final String? idSatuan;
  final String? idCity;
  final String? hargaProduk;
  final String? nameSatuan;
  final String? imageProduk;
  final String? createdAt;
  final String? updatedAt;

  ProductModel copyWith({
    String? idCartDetail,
    String? idCart,
    String? qtyCartDetail,
    String? idProduk,
    String? idMasterProduk,
    String? namaProduk,
    String? idSatuan,
    String? idCity,
    String? hargaProduk,
    String? nameSatuan,
    String? imageProduk,
    int? stok,
    String? createdAt,
    String? updatedAt,
  }) {
    return ProductModel(
      idCartDetail: idCartDetail ?? this.idCartDetail,
      idCart: idCart ?? this.idCart,
      qtyCartDetail: qtyCartDetail ?? this.qtyCartDetail,
      idProduk: idProduk ?? this.idProduk,
      idMasterProduk: idMasterProduk ?? this.idMasterProduk,
      namaProduk: namaProduk ?? this.namaProduk,
      idSatuan: idSatuan ?? this.idSatuan,
      idCity: idCity ?? this.idCity,
      hargaProduk: hargaProduk ?? this.hargaProduk,
      nameSatuan: nameSatuan ?? this.nameSatuan,
      imageProduk: imageProduk ?? this.imageProduk,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() => {
    'id_cart_detail': idCartDetail ?? '',
    'id_cart': idCart ?? '',
    'qty_cart_detail': qtyCartDetail ?? '',
    'id_produk': idProduk ?? '',
    'id_master_produk': idMasterProduk ?? '',
    'nama_produk': namaProduk ?? '',
    'id_satuan': idSatuan ?? '',
    'id_city': idCity ?? '',
    'harga_produk': hargaProduk ?? '',
    'name_satuan': nameSatuan ?? '',
    'img_produk': imageProduk ?? '',
    'created_at': createdAt ?? '',
    'updated_at': updatedAt ?? '',
  };

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      idCartDetail: json['id_cart_detail'] ?? '',
      idCart: json['id_cart'] ?? '',
      qtyCartDetail: json['qty_cart_detail'] ?? '',
      idProduk: json['id_produk'] ?? '',
      idMasterProduk: json['id_master_produk'] ?? '',
      namaProduk: json['nama_produk'] ?? '',
      idSatuan: json['id_satuan'] ?? '',
      idCity: json['id_city'] ?? '',
      hargaProduk: json['harga_produk'] ?? '',
      nameSatuan: json['name_satuan'] ?? '',
      imageProduk: json['img_produk'] ?? json['img_master_produk'] ?? '',
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
    );
  }
}
