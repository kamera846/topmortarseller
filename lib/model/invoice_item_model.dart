class InvoiceItemModel {
  final String idProduct;
  final String isBonus;
  final String imgProduk;
  final String namaProduk;
  final String price;
  final String qtyProduk;
  final String amount;
  final String createdAt;
  final String updatedAt;
  final String deletedAt;

  InvoiceItemModel({
    required this.idProduct,
    required this.isBonus,
    required this.imgProduk,
    required this.namaProduk,
    required this.price,
    required this.qtyProduk,
    required this.amount,
    required this.createdAt,
    required this.updatedAt,
    required this.deletedAt,
  });

  InvoiceItemModel copyWith({
    String? idProduct,
    String? isBonus,
    String? imgProduk,
    String? namaProduk,
    String? price,
    String? qtyProduk,
    String? amount,
    String? createdAt,
    String? updatedAt,
    String? deletedAt,
  }) {
    return InvoiceItemModel(
      idProduct: idProduct ?? this.idProduct,
      isBonus: isBonus ?? this.isBonus,
      imgProduk: imgProduk ?? this.imgProduk,
      namaProduk: namaProduk ?? this.namaProduk,
      price: price ?? this.price,
      qtyProduk: qtyProduk ?? this.qtyProduk,
      amount: amount ?? this.amount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }

  Map<String, dynamic> toJson() => {
    'is_produk': idProduct,
    'is_bonus': isBonus,
    'img_produk': imgProduk,
    'nama_produk': namaProduk,
    'price': price,
    'qty_produk': qtyProduk,
    'amount': amount,
    'created_at': createdAt,
    'updated_at': updatedAt,
    'deleted_at': deletedAt,
  };

  factory InvoiceItemModel.fromJson(Map<String, dynamic> json) {
    return InvoiceItemModel(
      idProduct: json['id_produk'] ?? '',
      isBonus: json['is_bonus'] ?? '',
      imgProduk: json['img_produk'] ?? '',
      namaProduk: json['nama_produk'] ?? '',
      price: json['price'] ?? '',
      qtyProduk: json['qty_produk'] ?? '',
      amount: json['amount'] ?? '',
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
      deletedAt: json['deleted_at'] ?? '',
    );
  }
}
