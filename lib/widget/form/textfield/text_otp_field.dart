import 'package:flutter/material.dart';
import 'package:topmortarseller/util/colors/color.dart';

class MOtpForm extends StatefulWidget {
  const MOtpForm({
    super.key,
    this.otpLength = 6,
    this.errorText,
    required this.onChange,
    required this.onCompleted,
  });

  final int otpLength;
  final String? errorText;
  final Function(String) onChange;
  final Function(String) onCompleted;

  @override
  State<MOtpForm> createState() => _MOtpFormState();
}

class _MOtpFormState extends State<MOtpForm> {
  final List<TextEditingController> _controllers = [];
  final List<FocusNode> _focusNodes = [];
  late String _otp;

  @override
  void initState() {
    super.initState();
    _otp = '';
    for (int i = 0; i < widget.otpLength; i++) {
      _controllers.add(TextEditingController());
      _focusNodes.add(FocusNode());
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _onChanged(String value, int index) {
    _otp = _controllers.map((c) => c.text).join();
    widget.onChange(_otp);
    if (value.length == 1) {
      if (index < widget.otpLength - 1) {
        FocusScope.of(context).nextFocus();
      } else {
        FocusScope.of(context).unfocus();
        widget.onCompleted(_otp);
      }
    } else if (value.isEmpty && index > 0) {
      FocusScope.of(context).previousFocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(widget.otpLength, (index) {
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              width: 40,
              child: TextField(
                controller: _controllers[index],
                focusNode: _focusNodes[index],
                onChanged: (value) => _onChanged(value, index),
                textAlign: TextAlign.center,
                keyboardType: TextInputType.number,
                maxLength: 1,
                decoration: InputDecoration(
                  counterText: '',
                  enabledBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: cDark400, width: 1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: cPrimary100, width: 2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                      color: cDark200,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            );
          }),
        ),
        if (widget.errorText != null)
          Text(
            widget.errorText ?? '',
            style: Theme.of(context)
                .textTheme
                .bodySmall!
                .copyWith(color: cPrimary100),
          ),
      ],
    );
  }
}
