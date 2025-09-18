class DiscountExtra {
  final String? discountName;
  final String discountValue;
  final String discountMaxDate;

  const DiscountExtra({
    this.discountName,
    this.discountValue = '',
    this.discountMaxDate = '',
  });

  factory DiscountExtra.fromJson(Map<String, dynamic> json) {
    return DiscountExtra(
      discountName: json['discount_name'],
      discountValue: json['discount_value'] ?? '0',
      discountMaxDate: json['discount_max_date'] ?? '',
    );
  }
}
