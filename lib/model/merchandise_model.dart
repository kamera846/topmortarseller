class MerchandiseModel {
  final String idMerchandise;
  final String nameMerchandise;
  final String descMerchandise;
  final String priceMerchandise;
  final String imgMerchandise;
  final String createdAt;
  final String updatedAt;

  const MerchandiseModel({
    this.idMerchandise = "",
    this.nameMerchandise = "",
    this.descMerchandise = "",
    this.priceMerchandise = "",
    this.imgMerchandise = "",
    this.createdAt = "",
    this.updatedAt = "",
  });

  int? get pointCost {
    final value = int.tryParse(priceMerchandise);
    return value != null && value > 0 ? value : null;
  }

  factory MerchandiseModel.fromJson(Map<String, dynamic> json) {
    return MerchandiseModel(
      idMerchandise: json['id_merchandise']?.toString() ?? "",
      nameMerchandise: json['name_merchandise'] ?? "",
      descMerchandise: json['desc_merchandise'] ?? "",
      priceMerchandise: json['price_merchandise']?.toString() ?? "",
      imgMerchandise: json['img_merchandise'] ?? "",
      createdAt: json['created_at'] ?? "",
      updatedAt: json['updated_at'] ?? "",
    );
  }
}
