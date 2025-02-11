import 'package:flutter/material.dart';

enum StatusOrder {
  diproses,
  dikirim,
  invoice,
  selesai,
}

class OrderTabsModel {
  final Widget header;
  final Widget body;

  OrderTabsModel({
    required this.header,
    required this.body,
  });

  OrderTabsModel copyWith({
    Widget? header,
    Widget? body,
  }) {
    return OrderTabsModel(
      header: header ?? this.header,
      body: body ?? this.body,
    );
  }
}
