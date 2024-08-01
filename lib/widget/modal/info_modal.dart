import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:topmortarseller/util/colors/color.dart';

class MInfoModal extends StatelessWidget {
  const MInfoModal({
    super.key,
    required this.title,
    this.contentName,
    this.contentDescription,
    this.cancelText = 'Batal',
    this.confirmText = 'Oke',
    this.contentIcon,
    this.onConfirm,
    this.onCancel,
  });

  final String title;
  final String? contentName;
  final String? contentDescription;
  final String? cancelText;
  final String? confirmText;
  final IconData? contentIcon;
  final VoidCallback? onConfirm;
  final VoidCallback? onCancel;

  @override
  Widget build(BuildContext context) {
    List<Widget> actions = [];

    if (cancelText != null) {
      actions.add(
        TextButton(
          onPressed: onCancel,
          child: Text(cancelText!),
        ),
      );
    }

    if (confirmText != null) {
      actions.add(
        TextButton(
          onPressed: onConfirm,
          child: Text(confirmText!),
        ),
      );
    }

    return CupertinoAlertDialog(
      title: Text(title),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          contentIcon != null
              ? IconButton.outlined(
                  onPressed: () {},
                  icon: Icon(contentIcon),
                )
              : Container(),
          contentName != null
              ? Text(
                  contentName!,
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium!
                      .copyWith(color: cDark100),
                )
              : Container(),
          contentDescription != null
              ? Text(
                  contentDescription!,
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium!
                      .copyWith(color: cDark300),
                )
              : Container(),
        ],
      ),
      actions: actions,
    );
  }
}
