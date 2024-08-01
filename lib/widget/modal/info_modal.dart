import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:topmortarseller/util/colors/color.dart';

class MInfoModal extends StatelessWidget {
  const MInfoModal({
    super.key,
    this.title,
    this.contentName,
    this.contentDescription,
    this.cancelText = 'Batal',
    this.confirmText = 'Oke',
    this.contentIcon,
    this.contentIconColor,
    this.onConfirm,
    this.onCancel,
  });

  final String? title;
  final String? contentName;
  final String? contentDescription;
  final String? cancelText;
  final String? confirmText;
  final IconData? contentIcon;
  final Color? contentIconColor;
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

    return CupertinoPopupSurface(
      isSurfacePainted: false,
      child: CupertinoAlertDialog(
        title: title != null ? Text(title!) : null,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            contentIcon != null
                ? Container(
                    margin: const EdgeInsets.all(8),
                    child: Icon(
                      contentIcon,
                      color: contentIconColor ?? cPrimary100,
                      size: 32,
                    ),
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
                        .copyWith(color: cDark200),
                  )
                : Container(),
          ],
        ),
        actions: actions,
      ),
    );
  }
}
