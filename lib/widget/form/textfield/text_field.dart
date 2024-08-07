import 'package:flutter/material.dart';
import 'package:topmortarseller/util/colors/color.dart';

class MTextField extends StatefulWidget {
  const MTextField({
    required this.label,
    required this.onChanged,
    super.key,
    this.id,
    this.value,
    this.validator,
    this.hint,
    this.helper,
    this.errorText,
    this.maxLength,
    this.maxLines = 1,
    this.onSubmitted,
    this.obscure = false,
    this.enabled = true,
    this.prefixIcon,
    this.suffixIcon,
    this.keyboardType = TextInputType.text,
    this.margin = const EdgeInsets.only(
      bottom: 12,
    ),
    this.inputAction,
    this.rightContent,
    this.controller,
  });
  final String? id;
  final String label;
  final String? value;
  final String? hint;
  final String? helper;
  final String? errorText;
  final String? Function(String?)? validator;
  final bool obscure;
  final bool enabled;
  final int? maxLength;
  final int? maxLines;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final Function(String) onChanged;
  final Function(String)? onSubmitted;
  final TextInputType keyboardType;
  final EdgeInsets margin;
  final Widget? rightContent;
  final TextInputAction? inputAction;
  final TextEditingController? controller;

  @override
  State<MTextField> createState() => _MTextFieldState();
}

class _MTextFieldState extends State<MTextField> {
  late FocusNode focusNode;
  bool _isFocused = false;

  @override
  void initState() {
    focusNode = FocusNode();
    focusNode.addListener(() {
      setState(() {
        _isFocused = focusNode.hasFocus;
      });
    });
    super.initState();
  }

  @override
  void dispose() {
    focusNode.dispose();
    super.dispose();
  }

  focus() {
    focusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> listItem = [];
    EdgeInsets inputPadding = const EdgeInsets.all(0);

    if (widget.prefixIcon == null && widget.prefixIcon == null) {
      inputPadding = const EdgeInsets.only(left: 16, right: 16);
    } else if (widget.prefixIcon == null) {
      inputPadding = const EdgeInsets.only(left: 16);
    } else if (widget.suffixIcon == null) {
      inputPadding = const EdgeInsets.only(right: 16);
    }

    listItem.add(
      Container(
        padding: inputPadding,
        decoration: BoxDecoration(
          color: cDark500,
          borderRadius: const BorderRadius.all(
            Radius.circular(8),
          ),
          border: Border.all(
            color: _isFocused ? cPrimary100 : cDark400,
            width: _isFocused ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: TextFormField(
                keyboardType: widget.keyboardType,
                textInputAction: widget.inputAction,
                enabled: widget.enabled,
                controller: widget.controller,
                focusNode: focusNode,
                validator: widget.validator,
                maxLength: widget.maxLength,
                maxLines: widget.maxLines,
                obscureText: widget.obscure,
                style: const TextStyle(color: cDark200),
                decoration: InputDecoration(
                  labelText: widget.label,
                  labelStyle:
                      TextStyle(color: _isFocused ? cPrimary100 : cDark300),
                  prefixIcon: widget.prefixIcon == null
                      ? null
                      : Icon(
                          widget.prefixIcon,
                        ),
                  prefixIconColor: _isFocused ? cPrimary100 : cDark300,
                  suffixIcon: widget.suffixIcon == null
                      ? null
                      : Icon(
                          widget.suffixIcon,
                        ),
                  suffixIconColor: _isFocused ? cPrimary100 : cDark300,
                  helperText: widget.helper,
                  hintText: widget.hint,
                  enabledBorder: InputBorder.none,
                  border: InputBorder.none,
                ),
                onChanged: (value) {
                  widget.onChanged(value);
                },
                onFieldSubmitted: (value) {
                  if (widget.onSubmitted != null) widget.onSubmitted!(value);
                },
              ),
            ),
            widget.rightContent ?? Container(),
          ],
        ),
      ),
    );

    if (widget.errorText != null) {
      listItem.add(
        Text(
          widget.errorText ?? '',
          style: Theme.of(context)
              .textTheme
              .bodySmall!
              .copyWith(color: cPrimary100),
        ),
      );
    }

    return Container(
      margin: widget.margin,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: listItem,
      ),
    );
  }
}
