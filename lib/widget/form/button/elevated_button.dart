import 'package:flutter/material.dart';
import 'package:topmortarseller/util/colors/color.dart';

class MElevatedButton extends StatefulWidget {
  const MElevatedButton({
    super.key,
    required this.title,
    required this.onPressed,
    this.isFullWidth = false,
  });

  final String title;
  final void Function() onPressed;
  final bool isFullWidth;

  @override
  State<MElevatedButton> createState() => _MElevatedButtonState();
}

class _MElevatedButtonState extends State<MElevatedButton> {
  @override
  Widget build(BuildContext context) {
    Widget textWidget = Text(
      widget.title,
      textAlign: TextAlign.center,
      style: Theme.of(context).textTheme.titleMedium!.copyWith(
            color: cWhite,
          ),
    );

    return ElevatedButton(
      onPressed: widget.onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: cPrimary100,
        foregroundColor: cWhite,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      ),
      child: widget.isFullWidth
          ? SizedBox(
              width: MediaQuery.of(context).size.width,
              child: textWidget,
            )
          : textWidget,
    );
  }
}
