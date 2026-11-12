class PointModel {
  PointModel({
    required this.idPoint,
    required this.idContact,
    required this.idInvoice,
    required this.sourcePoint,
    required this.valPoint,
    required this.idPointRedeem,
    required this.createdAt,
    required this.updatedAt,
    required this.deletedAt,
  });

  final String idPoint;
  final String idContact;
  final String idInvoice;
  final String sourcePoint;
  final String valPoint;
  final String? idPointRedeem;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? deletedAt;

  bool get isRedeemed => idPointRedeem != null;

  String get formattedValue {
    final value = valPoint.trim().replaceFirst(RegExp(r'^[+-]'), '');
    return '${isRedeemed ? '−' : '+'}${value.isEmpty ? '0' : value}';
  }

  PointModel copyWith({
    String? idPoint,
    String? idContact,
    String? idInvoice,
    String? sourcePoint,
    String? valPoint,
    String? idPointRedeem,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
  }) {
    return PointModel(
      idPoint: idPoint ?? this.idPoint,
      idContact: idContact ?? this.idContact,
      idInvoice: idInvoice ?? this.idInvoice,
      sourcePoint: sourcePoint ?? this.sourcePoint,
      valPoint: valPoint ?? this.valPoint,
      idPointRedeem: idPointRedeem ?? this.idPointRedeem,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }

  factory PointModel.fromJson(Map<String, dynamic> json) {
    return PointModel(
      idPoint: json["id_point"]?.toString() ?? "",
      idContact: json["id_contact"]?.toString() ?? "",
      idInvoice: json["id_invoice"]?.toString() ?? "",
      sourcePoint: json["source_point"]?.toString() ?? "",
      valPoint: json["val_point"]?.toString() ?? "",
      idPointRedeem: json["id_point_redeem"]?.toString(),
      createdAt: DateTime.tryParse(json["created_at"] ?? ""),
      updatedAt: DateTime.tryParse(json["updated_at"] ?? ""),
      deletedAt: DateTime.tryParse(json["deleted_at"] ?? ""),
    );
  }

  Map<String, dynamic> toJson() => {
    "id_point": idPoint,
    "id_contact": idContact,
    "id_invoice": idInvoice,
    "source_point": sourcePoint,
    "val_point": valPoint,
    "id_point_redeem": idPointRedeem,
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
    "deleted_at": deletedAt?.toIso8601String(),
  };

  @override
  String toString() {
    return "$idPoint, $idContact, $idInvoice, $sourcePoint, $valPoint, $idPointRedeem, $createdAt, $updatedAt, $deletedAt, ";
  }
}
