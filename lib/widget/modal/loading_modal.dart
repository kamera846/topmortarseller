import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:topmortarseller/util/colors/color.dart';

class LoadingModal extends StatelessWidget {
  const LoadingModal({super.key, this.message, this.androidBgColor});

  final String? message;
  final Color? androidBgColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: androidBgColor ?? cDark100.withValues(alpha: 0.5),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Platform.isIOS
              ? const CupertinoActivityIndicator(color: cWhite, radius: 15.0)
              : const RefreshProgressIndicator(
                  color: cPrimary100,
                  backgroundColor: cWhite,
                ),
          if (message != null) ...[
            const SizedBox(height: 12),
            Text(message!, style: const TextStyle(color: cWhite)),
          ],
        ],
      ),
    );
  }
}
