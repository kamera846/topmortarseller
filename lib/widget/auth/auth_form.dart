import 'package:flutter/material.dart';
import 'package:topmortarseller/data/auth_settings.dart';
import 'package:topmortarseller/models/auth_settings_model.dart';
import 'package:topmortarseller/screens/auth_screen.dart';
import 'package:topmortarseller/util/colors/color.dart';
import 'package:topmortarseller/util/validator/validator.dart';
import 'package:topmortarseller/widget/form/button/elevated_button.dart';
import 'package:topmortarseller/widget/form/button/text_button.dart';
import 'package:topmortarseller/widget/form/textfield/text_field.dart';
import 'package:topmortarseller/widget/form/textfield/text_otp_field.dart';

class AuthFormWidget extends StatefulWidget {
  const AuthFormWidget({super.key, this.authType = AuthType.login});

  final AuthType authType;

  @override
  State<AuthFormWidget> createState() => _AuthFormWidgetState();
}

class _AuthFormWidgetState extends State<AuthFormWidget> {
  bool _isPasswordHidden = true;

  void _forgotButton() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (ctx) => const AuthScreen(
          authType: AuthType.forgot,
        ),
      ),
    );
  }

  void _elevatedButtonAction() {
    final authType = widget.authType;

    if (authType == AuthType.forgot) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (ctx) => const AuthScreen(
            authType: AuthType.otp,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        widget.authType != AuthType.login
            ? Hero(
                tag: AuthTagHero.backButtonAuth,
                child: Row(
                  children: [
                    TextButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      label: const Text('Kembali'),
                      style: TextButton.styleFrom(
                        foregroundColor: cDark600,
                        padding: const EdgeInsets.all(0),
                      ),
                      icon: const Icon(
                        Icons.arrow_circle_left_rounded,
                      ),
                    ),
                  ],
                ),
              )
            : Container(),
        widget.authType != AuthType.otp
            ? MTextField(
                label: 'Nomor Telpon',
                inputAction: TextInputAction.next,
                prefixIcon: Icons.phone,
                keyboardType: TextInputType.phone,
                validator: Validator.number,
                onChanged: (value) {},
              )
            : Container(),
        widget.authType == AuthType.login
            ? MTextField(
                label: 'Kata Sandi',
                inputAction: TextInputAction.done,
                obscure: _isPasswordHidden,
                prefixIcon: Icons.lock_outline,
                validator: Validator.required,
                onChanged: (value) {},
                rightContent: TextButton(
                  onPressed: () {
                    setState(() {
                      _isPasswordHidden = !_isPasswordHidden;
                    });
                  },
                  child: Text(
                    _isPasswordHidden ? 'Tampilkan' : 'Sembunyikan',
                    style: Theme.of(context).textTheme.bodySmall!.copyWith(
                          color: cDark600,
                        ),
                  ),
                ),
              )
            : Container(),
        widget.authType == AuthType.otp
            ? MOtpForm(onCompleted: (otp) {})
            : Container(),
        const SizedBox(height: 24),
        MElevatedButton(
          onPressed: _elevatedButtonAction,
          isFullWidth: true,
          title: authSettings[widget.authType]!.elevatedButtonText,
        ),
        widget.authType == AuthType.login
            ? const SizedBox(height: 8)
            : Container(),
        widget.authType == AuthType.login
            ? Hero(
                tag: AuthTagHero.forgotButtonAuth,
                child: MTextButton(
                  onPressed: _forgotButton,
                  title: 'Lupa Kata Sandi',
                ),
              )
            : Container(),
      ],
    );
  }
}
