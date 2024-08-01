import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:topmortarseller/data/auth_settings.dart';
import 'package:topmortarseller/model/auth_settings_model.dart';
import 'package:topmortarseller/screen/auth_screen.dart';
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

    if (authType == AuthType.register || authType == AuthType.resetPassword) {
      _showCustomDialog(context);
    }

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

    if (authType == AuthType.otp) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (ctx) => const AuthScreen(
            authType: AuthType.resetPassword,
          ),
        ),
      );
    }
  }

  void _showCustomDialog(BuildContext context) {
    final authType = widget.authType;

    Widget storeInfoModal = MInfoModal(
      title: 'Apa benar ini toko anda',
      contentName: 'Barokah Jaya Mandiri',
      contentDescription: 'Jl Anggrek 3 asrikaton kec. pakis malang',
      contentIcon: Icons.storefront_outlined,
      onCancel: () {
        Navigator.of(context).pop();
      },
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
      title: 'Yeayy, berhasil',
      contentName: 'Password Berhasil Direset',
      contentDescription: 'Silahkan login menggunakan password anda yang baru.',
      contentIcon: Icons.change_circle_rounded,
      cancelText: null,
      onConfirm: () {
        Navigator.of(context).pop();
        Navigator.of(context).pop();
      },
    );
    if (authType == AuthType.register || authType == AuthType.resetPassword) {
      showDialog(
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
      ));
    }

    if (isPhoneFieldShow) {
      formList.add(
        MTextField(
          label: 'Nomor Telpon',
          inputAction: TextInputAction.next,
          prefixIcon: Icons.phone,
          keyboardType: TextInputType.phone,
          validator: Validator.number,
          onChanged: (value) {},
        ),
      );
    }

    if (isPasswordFieldShow) {
      formList.add(
        MTextField(
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
        ),
      );
    }

    if (isConfirmPasswordFieldShow) {
      formList.add(
        MTextField(
          label: 'Konfirmasi Kata Sandi',
          inputAction: TextInputAction.done,
          obscure: _isConfirmPasswordHidden,
          prefixIcon: Icons.lock_outline,
          validator: Validator.required,
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
                    color: cDark600,
                  ),
            ),
          ),
        ),
      );
    }

    if (isOtpFieldShow) {
      formList.add(
        MOtpForm(onCompleted: (otp) {}),
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
          tag: AuthTagHero.forgotButtonAuth,
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
