import 'package:flutter/material.dart';
import 'package:topmortarseller/util/colors/color.dart';

class MElevatedButton extends StatefulWidget {
  const MElevatedButton({
    super.key,
    required this.title,
    required this.onPressed,
    this.isFullWidth = false,
    this.enabled = true,
  });

  final String title;
  final void Function() onPressed;
  final bool isFullWidth;
  final bool enabled;

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
        color: widget.enabled ? cWhite : cDark300,
      ),
    );

    return Semantics(
      label: 'Tombol ${widget.title}',
      child: ElevatedButton(
        onPressed: widget.enabled ? widget.onPressed : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: widget.enabled ? cPrimary100 : cDark400,
          foregroundColor: widget.enabled ? cWhite : cDark300,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        ),
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
