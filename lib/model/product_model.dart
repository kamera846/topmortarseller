class ProductModel {
  const ProductModel(
      {this.idProduk,
      this.namaProduk,
      this.idCity,
      this.hargaProduk,
      this.imageProduk,
      this.stok,
      this.checkoutCount});

  final String? idProduk;
  final String? namaProduk;
  final String? idCity;
  final String? hargaProduk;
  final String? imageProduk;
  final int? stok;
  final String? checkoutCount;

  ProductModel copyWith({
    String? idProduk,
    String? namaProduk,
    String? idCity,
    String? hargaProduk,
    String? imageProduk,
    int? stok,
    String? checkoutCount,
  }) {
    return ProductModel(
      idProduk: idProduk ?? this.idProduk,
      namaProduk: namaProduk ?? this.namaProduk,
      idCity: idCity ?? this.idCity,
      hargaProduk: hargaProduk ?? this.hargaProduk,
      imageProduk: imageProduk ?? this.imageProduk,
      stok: stok ?? this.stok,
      checkoutCount: checkoutCount ?? this.checkoutCount,
    );
  }

  Map<String, dynamic> toJson() => {
        'id_produk': idProduk ?? '',
        'nama_produk': namaProduk ?? '',
        'id_city': idCity ?? '',
        'harga_produk': hargaProduk ?? '',
        'image_produk': imageProduk ?? '',
        'stok': stok ?? 0,
      };

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      idProduk: json['id_produk'] ?? '',
      namaProduk: json['nama_produk'] ?? '',
      idCity: json['id_city'] ?? '',
      hargaProduk: json['harga_produk'] ?? '',
      imageProduk: json['image_produk'] ?? '',
      stok: json['stok'] ?? 0,
    );
  }
}
