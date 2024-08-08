import 'package:flutter/material.dart';
import 'package:topmortarseller/util/tag_hero.dart';
import 'package:topmortarseller/model/auth_settings_model.dart';
import 'package:topmortarseller/widget/auth/auth_footer.dart';
import 'package:topmortarseller/widget/auth/auth_form.dart';
import 'package:topmortarseller/widget/auth/auth_header.dart';
import 'package:topmortarseller/util/colors/color.dart';
import 'package:topmortarseller/widget/modal/loading_modal.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key, this.authType = AuthType.login});

  final AuthType authType;

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                  isLoading: (state) {
                    setState(() {
                      _isLoading = state;
                    });
                  },
                ),
                Hero(
                  tag: TagHero.dividerAuth,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: widget.authType == AuthType.login
                        ? const Divider(color: cDark500)
                        : Container(),
                  ),
                ),
                AuthFooterWidget(authType: widget.authType),
              ],
            ),
          ),
          if (_isLoading) const LoadingModal()
        ]),
      ),
    );
  }
}
