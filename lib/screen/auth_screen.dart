import 'package:flutter/material.dart';
import 'package:topmortarseller/model/contact_model.dart';
import 'package:topmortarseller/util/enum.dart';
import 'package:topmortarseller/widget/auth/auth_footer.dart';
import 'package:topmortarseller/widget/auth/auth_form.dart';
import 'package:topmortarseller/widget/auth/auth_header.dart';
import 'package:topmortarseller/widget/modal/loading_modal.dart';
import 'package:upgrader/upgrader.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({
    super.key,
    this.authType = AuthType.login,
    this.userData,
  });

  final AuthType authType;
  final ContactModel? userData;

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool _isLoading = false;
  ContactModel? _userData;

  @override
  void initState() {
    super.initState();
    _userData = widget.userData;
  }

  @override
  Widget build(BuildContext context) {
    return UpgradeAlert(
      upgrader: Upgrader(
        debugLogging: true,
        languageCode: 'id',
        durationUntilAlertAgain: const Duration(seconds: 1),
      ),
      barrierDismissible: false,
      showLater: false,
      showReleaseNotes: false,
      showIgnore: false,
      child: Scaffold(
        body: SafeArea(
          child: Stack(children: [
            SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
              child: Column(
                children: [
                  AuthHeaderWidget(authType: widget.authType),
                  const SizedBox(height: 48),
                  AuthFormWidget(
                    authType: widget.authType,
                    userData: _userData,
                    isLoading: (state) {
                      setState(() {
                        _isLoading = state;
                      });
                    },
                  ),
                  AuthFooterWidget(authType: widget.authType),
                ],
              ),
            ),
            if (_isLoading) const LoadingModal()
          ]),
        ),
      ),
    );
  }
}
