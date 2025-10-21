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

  factory MerchandiseModel.fromJson(Map<String, dynamic> json) {
    return MerchandiseModel(
      idMerchandise: json['id_merchandise'] ?? "",
      nameMerchandise: json['name_merchandise'] ?? "",
      descMerchandise: json['desc_merchandise'] ?? "",
      priceMerchandise: json['price_merchandise'] ?? "",
      imgMerchandise: json['img_merchandise'] ?? "",
      createdAt: json['created_at'] ?? "",
      updatedAt: json['updated_at'] ?? "",
    );
  }
}
