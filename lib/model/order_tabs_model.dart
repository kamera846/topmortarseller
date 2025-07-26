import 'package:flutter/material.dart';
import 'package:topmortarseller/screen/products/order_screen.dart';

class OrderTabsModel {
  final Tab header;
  final ListOrder body;

  OrderTabsModel({required this.header, required this.body});

  OrderTabsModel copyWith({Tab? header, ListOrder? body}) {
    return OrderTabsModel(
      header: header ?? this.header,
      body: body ?? this.body,
    );
  }
}
