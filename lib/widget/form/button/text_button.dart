import 'package:flutter/material.dart';
import 'package:topmortarseller/util/colors/color.dart';

class MTextButton extends StatefulWidget {
  const MTextButton({
    super.key,
    required this.onPressed,
    required this.title,
    this.titleStyle,
    this.icon,
    this.iconAlignment,
    this.isFullWidth = false,
  });

  final String title;
  final ButtonStyle? titleStyle;
  final IconData? icon;
  final IconAlignment? iconAlignment;
  final void Function() onPressed;
  final bool isFullWidth;

  @override
  State<MTextButton> createState() => _MTextButtonState();
}

class _MTextButtonState extends State<MTextButton> {
  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Tombol ${widget.title}',
      child: TextButton.icon(
        icon: widget.icon != null ? Icon(widget.icon) : const SizedBox.shrink(),
        iconAlignment: widget.iconAlignment ?? IconAlignment.start,
        onPressed: widget.onPressed,
        label: Text(widget.title),
        style: widget.titleStyle ??
            TextButton.styleFrom(foregroundColor: cPrimary300),
      ),
    );
  }
}
