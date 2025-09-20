class FeedModel {
  const FeedModel({
    this.idKonten,
    this.titleKonten,
    this.imgKonten,
    this.createdAt,
    this.udpatedAt,
    this.linkKonten,
  });

  final String? idKonten;
  final String? titleKonten;
  final String? imgKonten;
  final String? createdAt;
  final String? udpatedAt;
  final String? linkKonten;

  Map<String, dynamic> toJson() => {
    'id_konten': idKonten ?? '',
    'title_konten': titleKonten ?? '',
    'img_konten': imgKonten ?? '',
    'created_at': createdAt ?? '',
    'udpated_at': udpatedAt ?? '',
    'link_konten': linkKonten ?? '',
  };

  factory FeedModel.fromJson(Map<String, dynamic> json) {
    return FeedModel(
      idKonten: json['id_konten'] ?? '',
      titleKonten: json['title_konten'] ?? '',
      imgKonten: json['img_konten'] ?? '',
      createdAt: json['created_at'] ?? '',
      udpatedAt: json['udpated_at'] ?? '',
      linkKonten: json['link_konten'] ?? '',
    );
  }
}
