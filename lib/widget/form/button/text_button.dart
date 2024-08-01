import 'package:flutter/material.dart';
import 'package:topmortarseller/util/colors/color.dart';

class MTextButton extends StatefulWidget {
  const MTextButton({
    super.key,
    required this.onPressed,
    required this.title,
    this.isFullWidth = false,
  });

  final String title;
  final void Function() onPressed;
  final bool isFullWidth;

  @override
  State<MTextButton> createState() => _MTextButtonState();
}

class _MTextButtonState extends State<MTextButton> {
  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: widget.onPressed,
      child: Text(
        widget.title,
        style: Theme.of(context).textTheme.titleSmall!.copyWith(
              color: cPrimary300,
            ),
      ),
    );
  }
}
