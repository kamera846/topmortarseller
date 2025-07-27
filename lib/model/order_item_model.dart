class OrderItemModel {
  final String idAppOrderDetail;
  final String idAppOrder;
  final String idProduk;
  final String imgProduk;
  final String nameProduk;
  final String priceProduk;
  final String qtyAppOrderDetail;
  final String totalAppOrderDetail;
  final String nameSatuan;
  final String createdAt;
  final String updatedAt;
  final String deletedAt;

  OrderItemModel({
    required this.idAppOrderDetail,
    required this.idAppOrder,
    required this.idProduk,
    required this.imgProduk,
    required this.nameProduk,
    required this.priceProduk,
    required this.qtyAppOrderDetail,
    required this.totalAppOrderDetail,
    required this.nameSatuan,
    required this.createdAt,
    required this.updatedAt,
    required this.deletedAt,
  });

  OrderItemModel copyWith({
    String? idAppOrderDetail,
    String? idAppOrder,
    String? idProduk,
    String? imgProduk,
    String? nameProduk,
    String? priceProduk,
    String? qtyAppOrderDetail,
    String? totalAppOrderDetail,
    String? nameSatuan,
    String? createdAt,
    String? updatedAt,
    String? deletedAt,
  }) {
    return OrderItemModel(
      idAppOrderDetail: idAppOrderDetail ?? this.idAppOrderDetail,
      idAppOrder: idAppOrder ?? this.idAppOrder,
      idProduk: idProduk ?? this.idProduk,
      imgProduk: imgProduk ?? this.imgProduk,
      nameProduk: nameProduk ?? this.nameProduk,
      priceProduk: priceProduk ?? this.priceProduk,
      qtyAppOrderDetail: qtyAppOrderDetail ?? this.qtyAppOrderDetail,
      totalAppOrderDetail: totalAppOrderDetail ?? this.totalAppOrderDetail,
      nameSatuan: nameSatuan ?? this.nameSatuan,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }

  Map<String, dynamic> toJson() => {
    'id_apporder_detail': idAppOrderDetail,
    'id_apporder': idAppOrder,
    'id_produk': idProduk,
    'img_produk': imgProduk,
    'name_produk': nameProduk,
    'price_produk': priceProduk,
    'qty_apporder_detail': qtyAppOrderDetail,
    'total_apporder_detail': totalAppOrderDetail,
    'name_satuan': nameSatuan,
    'created_at': createdAt,
    'updated_at': updatedAt,
    'deleted_at': deletedAt,
  };

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    return OrderItemModel(
      idAppOrderDetail: json['id_apporder'] ?? '',
      idAppOrder: json['id_apporder'] ?? '',
      idProduk: json['id_produk'] ?? '',
      imgProduk: json['img_produk'] ?? '',
      nameProduk: json['name_produk'] ?? '',
      priceProduk: json['price_produk'] ?? '',
      qtyAppOrderDetail: json['qty_apporder_detail'] ?? '',
      totalAppOrderDetail: json['total_apporder_detail'] ?? '',
      nameSatuan: json['name_satuan'] ?? '',
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
      deletedAt: json['deleted_at'] ?? '',
    );
  }
}
