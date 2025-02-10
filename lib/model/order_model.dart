import 'package:flutter/material.dart';
import 'package:topmortarseller/model/product_model.dart';

class OrderModel {
  final String orderDate;
  final String orderStatus;
  final List<Color> orderStatusColors;
  final List<ProductModel> orderItems;

  OrderModel({
    required this.orderDate,
    required this.orderStatus,
    required this.orderStatusColors,
    required this.orderItems,
  });
}
