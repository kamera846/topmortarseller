import 'package:flutter/material.dart';
import 'package:topmortarseller/util/colors/color.dart';

class LoadingItem extends StatelessWidget {
  const LoadingItem({
    super.key,
    this.isPrimaryTheme = false,
    this.height = 10,
    this.margin = const EdgeInsets.all(2),
  });

  final bool isPrimaryTheme;
  final double height;
  final EdgeInsetsGeometry margin;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      child: LinearProgressIndicator(
        minHeight: height,
        backgroundColor: isPrimaryTheme ? cPrimary500 : cDark500,
        color: isPrimaryTheme ? cPrimary400 : cDark400,
      ),
    );
  }
}
