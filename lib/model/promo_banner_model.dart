class PromoBannerModel {
  final String? idPromoTopseller;
  final String? namePromoTopseller;
  final String? imgPromoTopseller;
  final String? detailPromoTopseller;
  final String? createdAt;
  final String? updatedAt;

  const PromoBannerModel({
    this.idPromoTopseller,
    this.namePromoTopseller,
    this.imgPromoTopseller,
    this.detailPromoTopseller,
    this.createdAt,
    this.updatedAt,
  });

  factory PromoBannerModel.fromJson(Map<String, dynamic> json) {
    return PromoBannerModel(
      idPromoTopseller: json['id_promo_topseller'] ?? '',
      namePromoTopseller: json['name_promo_topseller'] ?? '',
      imgPromoTopseller: json['img_promo_topseller'] ?? '',
      detailPromoTopseller: json['detail_promo_topseller'] ?? '',
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
    );
  }
}
