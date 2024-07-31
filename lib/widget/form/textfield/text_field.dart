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
    this.keyboardType = TextInputType.text,
    this.maxLength,
    this.onSubmitted,
    this.obscure = false,
    this.enabled = true,
    this.prefixIcon,
    this.suffixIcon,
    this.margin = const EdgeInsets.only(
      bottom: 12,
    ),
  });
  final String? id;
  final String label;
  final String? value;
  final String? hint;
  final String? helper;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final bool obscure;
  final bool enabled;
  final int? maxLength;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final Function(String) onChanged;
  final Function(String)? onSubmitted;
  final EdgeInsets margin;

  @override
  State<MTextField> createState() => _MTextFieldState();
}

class _MTextFieldState extends State<MTextField> {
  TextEditingController textEditingController = TextEditingController();
  late FocusNode focusNode;
  bool _isFocused = false;

  @override
  void initState() {
    focusNode = FocusNode();
    textEditingController.text = widget.value ?? '';
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

  String getValue() {
    return textEditingController.text;
  }

  setValue(value) {
    textEditingController.text = value;
  }

  resetValue() {
    textEditingController.text = '';
  }

  focus() {
    focusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: widget.margin,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: cWhite,
        borderRadius: const BorderRadius.all(
          Radius.circular(8),
        ),
        border: Border.all(
          color: _isFocused ? cPrimary100 : cDark600,
          width: 1.0,
        ),
      ),
      child: TextFormField(
        keyboardType: widget.keyboardType,
        enabled: widget.enabled,
        controller: textEditingController,
        focusNode: focusNode,
        validator: widget.validator,
        maxLength: widget.maxLength,
        obscureText: widget.obscure,
        decoration: InputDecoration(
          labelText: widget.label,
          suffixIcon: Icon(
            widget.suffixIcon ?? Icons.abc,
          ),
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
    );
  }
}
