import 'package:flutter/material.dart';
import 'package:topmortarseller/util/colors/color.dart';

class MOutlinedButton extends StatefulWidget {
  const MOutlinedButton({
    super.key,
    required this.title,
    required this.onPressed,
    this.isFullWidth = false,
  });

  final String title;
  final void Function() onPressed;
  final bool isFullWidth;

  @override
  State<MOutlinedButton> createState() => _MOutlinedButtonState();
}

class _MOutlinedButtonState extends State<MOutlinedButton> {
  @override
  Widget build(BuildContext context) {
    Widget textWidget = Text(
      widget.title,
      style: Theme.of(context).textTheme.bodySmall!.copyWith(
            color: cPrimary100,
          ),
    );

    return Semantics(
      label: 'Tombol ${widget.title}',
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          foregroundColor: cPrimary100,
          side: const BorderSide(color: cDark400),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        onPressed: widget.onPressed,
        child: widget.isFullWidth
            ? SizedBox(
                width: MediaQuery.of(context).size.width,
                child: textWidget,
              )
            : textWidget,
      ),
    );
  }
}
