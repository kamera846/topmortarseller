// ignore_for_file: use_build_context_synchronously

import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:topmortarseller/model/contact_model.dart';
import 'package:topmortarseller/services/api.dart';
import 'package:topmortarseller/services/auth_api.dart';

import 'package:topmortarseller/util/auth_settings.dart';
import 'package:topmortarseller/util/enum.dart';
import 'package:topmortarseller/model/auth_settings_model.dart';
import 'package:topmortarseller/screen/auth_screen.dart';
import 'package:topmortarseller/screen/home_screen.dart';
import 'package:topmortarseller/util/colors/color.dart';
import 'package:topmortarseller/util/validator/validator.dart';
import 'package:topmortarseller/widget/form/button/elevated_button.dart';
import 'package:topmortarseller/widget/form/button/outlined_button.dart';
import 'package:topmortarseller/widget/form/button/text_button.dart';
import 'package:topmortarseller/widget/form/textfield/text_field.dart';
import 'package:topmortarseller/widget/form/textfield/text_otp_field.dart';
import 'package:topmortarseller/widget/modal/info_modal.dart';
import 'package:topmortarseller/widget/snackbar/show_snackbar.dart';

class AuthFormWidget extends StatefulWidget {
  const AuthFormWidget({
    super.key,
    this.authType = AuthType.login,
    this.isLoading,
    this.userData,
  });

  final AuthType authType;
  final Function(bool)? isLoading;
  final ContactModel? userData;

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
  ContactModel? _userData;

  @override
  void initState() {
    super.initState();
    _userData = widget.userData;
  }

  void _forgotButton() {
    _phoneController.text = '';
    _passwordController.text = '';
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (ctx) => const AuthScreen(
          authType: AuthType.forgot,
        ),
      ),
    );
  }

  void _outlinedButtonAction() {
    _phoneController.text = '';
    _passwordController.text = '';
    if (widget.authType == AuthType.register ||
        widget.authType == AuthType.forgot) {
      Navigator.pop(context);
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (ctx) => const AuthScreen(
          authType: AuthType.register,
        ),
      ),
    );
  }

  void _elevatedButtonAction() async {
    final authType = widget.authType;

    if (authType == AuthType.login) {
      loginHandler();
    }

    if (authType == AuthType.forgot) {
      registerHandler();
    }

    if (authType == AuthType.otp) {
      verifyOtp();
    }

    if (authType == AuthType.register) {
      registerHandler();
    }

    if (authType == AuthType.resetPassword) {
      resetPasswordHandler();
    }
  }

  void loginHandler() async {
    var phoneNumber = _phoneController.text;
    final password = _passwordController.text;
    final String? phoneValidator = Validator.phoneAuth(phoneNumber);
    final String? passwordValidator = Validator.passwordAuth(password);

    setState(() {
      _phoneError = phoneValidator;
      _passwordError = passwordValidator;
    });

    if (phoneValidator != null || passwordValidator != null) return;

    if (phoneNumber.startsWith('62')) {
      phoneNumber = '0${phoneNumber.substring(2)}';
    } else if (phoneNumber.startsWith('+62')) {
      phoneNumber = '0${phoneNumber.substring(3)}';
    } else if (phoneNumber.startsWith('8')) {
      phoneNumber = '0$phoneNumber';
    }

    setState(() => widget.isLoading!(true));

    try {
      final response = await AuthApiService().login(
        phoneNumber: phoneNumber,
        password: password,
      );

      if (response.statusCode == 200) {
        final responseBody = json.decode(response.body);
        final apiResponse = ApiResponse.fromJson(responseBody);

        if (apiResponse.code == 200) {
          if (apiResponse.data != null) {
            final userData = ContactModel.fromJson(apiResponse.data!);
            await saveLoginState();
            await saveContactModel(userData);
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (ctx) => HomeScreen(
                  userData: userData,
                ),
              ),
            );
            showSnackBar(context, apiResponse.msg);
          } else {
            showSnackBar(context, 'Response data is null!');
          }
        } else {
          showSnackBar(context, apiResponse.msg);
        }
      } else {
        showSnackBar(
            context, '$failedRequestText. Status Code: ${response.statusCode}');
      }
    } catch (e) {
      showSnackBar(context, '$failedRequestText. Exception: $e');
    } finally {
      setState(() => widget.isLoading!(false));
    }
  }

  void registerHandler() async {
    var phoneNumber = _phoneController.text;
    final String? phoneValidator = Validator.phoneAuth(phoneNumber);

    setState(() {
      _phoneError = phoneValidator;
    });

    if (phoneValidator != null) return;

    if (phoneNumber.startsWith('62')) {
      phoneNumber = '0${phoneNumber.substring(2)}';
    } else if (phoneNumber.startsWith('+62')) {
      phoneNumber = '0${phoneNumber.substring(3)}';
    } else if (phoneNumber.startsWith('8')) {
      phoneNumber = '0$phoneNumber';
    }

    setState(() => widget.isLoading!(true));

    try {
      final response =
          await AuthApiService().fetchRegister(phoneNumber: phoneNumber);

      if (response.statusCode == 200) {
        final responseBody = json.decode(response.body);
        final apiResponse = ApiResponse.fromJson(responseBody);

        if (apiResponse.code == 200) {
          setState(() {
            _userData = ContactModel.fromJson(apiResponse.data!);
          });
          if (_userData != null) {
            showCupertinoDialog(
              context: context,
              builder: (BuildContext context) {
                return MInfoModal(
                  title: 'Apa benar ini toko anda?',
                  contentName: _userData!.nama,
                  contentDescription: _userData!.address!.isEmpty
                      ? _userData!.storeOwner
                      : _userData!.address,
                  contentIcon: Icons.storefront_outlined,
                  cancelText: 'Bukan',
                  onCancel: () {
                    Navigator.of(context).pop();
                  },
                  confirmText: 'Oke, Lanjut',
                  onConfirm: () {
                    Navigator.of(context).pop();
                    requestOtpHandler();
                  },
                );
              },
            );
          }
        } else {
          showSnackBar(context, apiResponse.msg);
        }
      } else {
        showSnackBar(
            context, '$failedRequestText. Status Code: ${response.statusCode}');
      }
    } catch (e) {
      showSnackBar(context, '$failedRequestText. Exception: $e');
    } finally {
      setState(() => widget.isLoading!(false));
    }
  }

  void requestOtpHandler() async {
    setState(() => widget.isLoading!(true));

    try {
      final response = await AuthApiService().requestOtp(
        idContact: _userData!.idContact ?? '',
        idDistributor: _userData!.idDistributor ?? '',
      );

      if (response.statusCode == 200) {
        final responseBody = json.decode(response.body);
        final apiResponse = ApiResponse.fromJson(responseBody);

        if (apiResponse.code == 200) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: ((context) => AuthScreen(
                    authType: AuthType.otp,
                    userData: _userData!,
                  )),
            ),
          );
        }

        showSnackBar(context, apiResponse.msg);
      } else {
        showSnackBar(
            context, '$failedRequestText. Status Code: ${response.statusCode}');
      }
    } catch (e) {
      showSnackBar(context, '$failedRequestText. Exception: $e');
    } finally {
      setState(() => widget.isLoading!(false));
    }
  }

  void verifyOtp() async {
    final String? otpValidator = Validator.otpAuth(
      _otpController,
      _otpLength,
    );

    setState(() {
      _otpError = otpValidator;
    });

    if (otpValidator != null) return;

    setState(() => widget.isLoading!(true));

    try {
      final response = await AuthApiService().verifyOtp(
        idContact: _userData!.idContact ?? '',
        otp: _otpController ?? '',
      );

      if (response.statusCode == 200) {
        final responseBody = json.decode(response.body);
        final apiResponse = ApiResponse.fromJson(responseBody);

        if (apiResponse.code == 200) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (ctx) => AuthScreen(
                authType: AuthType.resetPassword,
                userData: _userData,
              ),
            ),
          );
        }

        showSnackBar(context, apiResponse.msg);
      } else {
        showSnackBar(
            context, '$failedRequestText. Status Code: ${response.statusCode}');
      }
    } catch (e) {
      showSnackBar(context, '$failedRequestText. Exception: $e');
    } finally {
      setState(() => widget.isLoading!(false));
    }
  }

  void resetPasswordHandler() async {
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

    setState(() => widget.isLoading!(true));

    try {
      final response = await AuthApiService().resetPassword(
        idContact: _userData!.idContact ?? '',
        password: _confirmPasswordController.text,
      );

      if (response.statusCode == 200) {
        final responseBody = json.decode(response.body);
        final apiResponse = ApiResponse.fromJson(responseBody);

        if (apiResponse.code == 200) {
          showCupertinoDialog(
            context: context,
            builder: (BuildContext context) {
              return MInfoModal(
                contentName: 'Yeayy, Proses Selesai!',
                contentDescription: apiResponse.msg,
                contentIcon: Icons.change_circle_rounded,
                contentIconColor: Colors.green.shade800,
                cancelText: null,
                onConfirm: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                },
              );
            },
          );
        } else {
          showSnackBar(context, apiResponse.msg);
        }
      } else {
        showSnackBar(
            context, '$failedRequestText. Status Code: ${response.statusCode}');
      }
    } catch (e) {
      showSnackBar(context, '$failedRequestText. Exception: $e');
    } finally {
      setState(() => widget.isLoading!(false));
    }
  }

  @override
  Widget build(BuildContext context) {
    final String? outlinedButtonDescription =
        authSettings[widget.authType]!.outlinedButtonDescription;
    final String? outlinedButtonText =
        authSettings[widget.authType]!.outlinedButtonText;
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
              MTextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                title: 'Kembali',
                icon: Icons.arrow_circle_left_rounded,
                titleStyle: TextButton.styleFrom(
                  foregroundColor: cDark100,
                  padding: const EdgeInsets.all(0),
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
          onChanged: (value) {
            var formattedValue = value.replaceAll(RegExp(r'[^0-9+]'), '');
            final String? phoneValidator = Validator.phoneAuth(formattedValue);
            setState(() {
              _phoneError = phoneValidator;
              _phoneController.text = formattedValue;
            });
          },
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
          onChanged: (value) {
            final String? passwordValidator = Validator.passwordAuth(value);
            setState(() {
              _passwordError = passwordValidator;
            });
          },
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
          onChanged: (value) {
            final String? passwordValidator = Validator.passwordAuth(value);
            setState(() {
              _confirmPasswordError = passwordValidator;
            });
          },
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
    formList.add(
      Hero(
        tag: TagHero.dividerAuth,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: widget.authType == AuthType.login
              ? const Divider(color: cDark500)
              : Container(),
        ),
      ),
    );
    formList.add(
      Hero(
        tag: TagHero.outlinedButtonContainerAuth,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            outlinedButtonDescription != null
                ? Text(
                    outlinedButtonDescription,
                    style: Theme.of(context).textTheme.bodySmall,
                  )
                : Container(),
            const SizedBox(width: 8),
            outlinedButtonText != null
                ? MOutlinedButton(
                    onPressed: _outlinedButtonAction,
                    title: outlinedButtonText,
                  )
                : Container(),
          ],
        ),
      ),
    );

    return Column(
      children: formList,
    );
  }
}
