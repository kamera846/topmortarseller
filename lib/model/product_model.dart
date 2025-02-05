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
  final String? stok;
  final String? checkoutCount;

  ProductModel copyWith({
    String? idProduk,
    String? namaProduk,
    String? idCity,
    String? hargaProduk,
    String? imageProduk,
    String? stok,
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
}
