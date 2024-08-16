import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:topmortarseller/util/colors/color.dart';

class LoadingModal extends StatelessWidget {
  const LoadingModal({
    super.key,
    this.message,
    this.androidBgColor,
  });

  final String? message;
  final Color? androidBgColor;

  @override
  Widget build(BuildContext context) {
    Widget iosContent = CupertinoPopupSurface(
      isSurfacePainted: false,
      child: SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            const CupertinoActivityIndicator(
              color: cPrimary100,
              radius: 20.0,
            ),
            if (message != null) ...[
              const SizedBox(height: 12),
              Text(
                message!,
                style: const TextStyle(color: cDark100),
              ),
            ]
          ],
        ),
      ),
    );
    Widget androidContent = Container(
      width: double.infinity,
      height: double.infinity,
      color: androidBgColor ?? cDark100.withOpacity(0.5),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          const RefreshProgressIndicator(
            color: cPrimary100,
            backgroundColor: cWhite,
          ),
          if (message != null)
            Text(
              message!,
              style: const TextStyle(color: cWhite),
            ),
        ],
      ),
    );
    return Center(child: Platform.isIOS ? iosContent : androidContent);
  }
}
