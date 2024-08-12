import 'package:flutter/material.dart';
import 'package:topmortarseller/util/colors/color.dart';

class LoadingItem extends StatelessWidget {
  const LoadingItem({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      margin: const EdgeInsets.all(2),
      child: const LinearProgressIndicator(
        minHeight: 10,
        backgroundColor: cPrimary500,
        color: cPrimary400,
      ),
    );
  }
}
