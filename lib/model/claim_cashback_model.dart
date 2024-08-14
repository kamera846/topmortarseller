class ClaimCashbackModel {
  const ClaimCashbackModel({
    this.data,
  });

  final String? data;

  Map<String, dynamic> toJson() => {
        'data': data ?? '',
      };

  factory ClaimCashbackModel.fromJson(Map<String, dynamic> json) {
    return ClaimCashbackModel(
      data: json['data'] ?? '',
    );
  }
}
