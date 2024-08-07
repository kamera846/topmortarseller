import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:topmortarseller/data/auth_settings.dart';
import 'package:topmortarseller/data/tag_hero.dart';
import 'package:topmortarseller/model/auth_settings_model.dart';
import 'package:topmortarseller/screen/auth_screen.dart';
import 'package:topmortarseller/screen/home_screen.dart';
import 'package:topmortarseller/util/colors/color.dart';
import 'package:topmortarseller/util/validator/validator.dart';
import 'package:topmortarseller/widget/form/button/elevated_button.dart';
import 'package:topmortarseller/widget/form/button/text_button.dart';
import 'package:topmortarseller/widget/form/textfield/text_field.dart';
import 'package:topmortarseller/widget/form/textfield/text_otp_field.dart';
import 'package:topmortarseller/widget/modal/info_modal.dart';

class AuthFormWidget extends StatefulWidget {
  const AuthFormWidget({super.key, this.authType = AuthType.login});

  final AuthType authType;

  @override
  State<AuthFormWidget> createState() => _AuthFormWidgetState();
}

class _AuthFormWidgetState extends State<AuthFormWidget> {
  final _otpLength = 6;
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  String? _otpController;
  String? _phoneError;
  String? _passwordError;
  String? _confirmPasswordError;
  String? _otpError;
  bool _isPasswordHidden = true;
  bool _isConfirmPasswordHidden = true;

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

    if (authType == AuthType.login) {
      final String? phoneValidator = Validator.phoneAuth(_phoneController.text);
      final String? passwordValidator =
          Validator.passwordAuth(_passwordController.text);

      setState(() {
        _phoneError = phoneValidator;
        _passwordError = passwordValidator;
      });

      if (phoneValidator != null || passwordValidator != null) return;
      _phoneController.text = '';
      _passwordController.text = '';

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (ctx) => const HomeScreen(),
        ),
      );
    }

    if (authType == AuthType.forgot) {
      final String? phoneValidator = Validator.phoneAuth(_phoneController.text);

      setState(() {
        _phoneError = phoneValidator;
      });

      if (phoneValidator != null) return;
      _phoneController.text = '';

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (ctx) => const AuthScreen(
            authType: AuthType.otp,
          ),
        ),
      );
    }

    if (authType == AuthType.otp) {
      final String? otpValidator =
          Validator.otpAuth(_otpController, _otpLength);

      setState(() {
        _otpError = otpValidator;
      });

      if (otpValidator != null) return;
      _otpController = '';

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (ctx) => const AuthScreen(
            authType: AuthType.resetPassword,
          ),
        ),
      );
    }

    if (authType == AuthType.register) {
      final String? phoneValidator = Validator.phoneAuth(_phoneController.text);

      setState(() {
        _phoneError = phoneValidator;
      });

      if (phoneValidator != null) return;
      _phoneController.text = '';

      _showCustomDialog(context);
    }

    if (authType == AuthType.resetPassword) {
      final String? passwordValidator =
          Validator.passwordAuth(_passwordController.text);
      final String? confirmPasswordValidator =
          Validator.passwordAuth(_confirmPasswordController.text);
      final String? passwordMatchesValidator = Validator.passwordMatches(
          _passwordController.text, _confirmPasswordController.text);

      setState(() {
        _passwordError = passwordValidator;
        _confirmPasswordError =
            confirmPasswordValidator ?? passwordMatchesValidator;
      });

      if (passwordValidator != null ||
          confirmPasswordValidator != null ||
          passwordMatchesValidator != null) return;
      _passwordController.text = '';
      _confirmPasswordController.text = '';

      _showCustomDialog(context);
    }
  }

  void _showCustomDialog(BuildContext context) {
    final authType = widget.authType;

    Widget storeInfoModal = MInfoModal(
      title: 'Apa benar ini toko anda?',
      contentName: 'Barokah Jaya Mandiri',
      contentDescription: 'Jl Anggrek 3 asrikaton kec. pakis malang',
      contentIcon: Icons.storefront_outlined,
      onCancel: () {
        Navigator.of(context).pop();
      },
      confirmText: 'Oke, Lanjut',
      onConfirm: () {
        Navigator.of(context).pop();
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: ((context) => const AuthScreen(
                  authType: AuthType.otp,
                )),
          ),
        );
      },
    );
    Widget successResetPasswordModal = MInfoModal(
      contentName: 'Password Berhasil Direset',
      contentDescription: 'login menggunakan password anda yang baru.',
      contentIcon: Icons.change_circle_rounded,
      contentIconColor: Colors.green.shade800,
      cancelText: null,
      onConfirm: () {
        Navigator.of(context).pop();
        Navigator.of(context).pop();
      },
    );
    if (authType == AuthType.register || authType == AuthType.resetPassword) {
      showCupertinoDialog(
        context: context,
        builder: (BuildContext context) {
          if (authType == AuthType.register) {
            return storeInfoModal;
          } else {
            return successResetPasswordModal;
          }
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> formList = [];
    final authType = widget.authType;
    bool isBackButtonShow = authType != AuthType.login;
    bool isPhoneFieldShow = authType == AuthType.login ||
        authType == AuthType.forgot ||
        authType == AuthType.register;
    bool isPasswordFieldShow =
        authType == AuthType.login || authType == AuthType.resetPassword;
    bool isConfirmPasswordFieldShow = authType == AuthType.resetPassword;
    bool isOtpFieldShow = widget.authType == AuthType.otp;
    bool isForgotButtonShow = authType == AuthType.login;

    if (isBackButtonShow) {
      formList.add(Hero(
        tag: TagHero.backButtonAuth,
        child: Container(
          margin: const EdgeInsets.only(bottom: 8),
          child: Row(
            children: [
              TextButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                },
                label: const Text('Kembali'),
                style: TextButton.styleFrom(
                  foregroundColor: cDark100,
                  padding: const EdgeInsets.all(0),
                ),
                icon: const Icon(
                  Icons.arrow_circle_left_rounded,
                ),
              ),
            ],
          ),
        ),
      ));
    }

    if (isPhoneFieldShow) {
      formList.add(
        MTextField(
          controller: _phoneController,
          label: 'Nomor Telpon',
          prefixIcon: Icons.phone,
          keyboardType: TextInputType.phone,
          errorText: _phoneError,
          onChanged: (value) {},
        ),
      );
    }

    if (isPasswordFieldShow) {
      formList.add(
        MTextField(
          controller: _passwordController,
          label: 'Kata Sandi',
          obscure: _isPasswordHidden,
          prefixIcon: Icons.lock_outline,
          errorText: _passwordError,
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
                    color: cDark300,
                  ),
            ),
          ),
        ),
      );
    }

    if (isConfirmPasswordFieldShow) {
      formList.add(
        MTextField(
          controller: _confirmPasswordController,
          label: 'Konfirmasi Kata Sandi',
          obscure: _isConfirmPasswordHidden,
          prefixIcon: Icons.lock_outline,
          errorText: _confirmPasswordError,
          onChanged: (value) {},
          rightContent: TextButton(
            onPressed: () {
              setState(() {
                _isConfirmPasswordHidden = !_isConfirmPasswordHidden;
              });
            },
            child: Text(
              _isConfirmPasswordHidden ? 'Tampilkan' : 'Sembunyikan',
              style: Theme.of(context).textTheme.bodySmall!.copyWith(
                    color: cDark300,
                  ),
            ),
          ),
        ),
      );
    }

    if (isOtpFieldShow) {
      formList.add(
        MOtpForm(
          errorText: _otpError,
          otpLength: _otpLength,
          onChange: (value) {
            _otpController = value;
          },
          onCompleted: (otp) {
            _otpController = otp;
          },
        ),
      );
    }

    formList.add(const SizedBox(height: 24));
    formList.add(
      MElevatedButton(
        onPressed: _elevatedButtonAction,
        isFullWidth: true,
        title: authSettings[widget.authType]!.elevatedButtonText,
      ),
    );

    if (isForgotButtonShow) {
      formList.add(const SizedBox(height: 8));
      formList.add(
        Hero(
          tag: TagHero.forgotButtonAuth,
          child: MTextButton(
            onPressed: _forgotButton,
            title: 'Lupa Kata Sandi',
          ),
        ),
      );
    }

    return Column(
      children: formList,
    );
  }
}
