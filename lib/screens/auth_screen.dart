import 'package:flutter/material.dart';
import 'package:topmortarseller/models/auth_settings_model.dart';
import 'package:topmortarseller/widget/auth/auth_footer.dart';
import 'package:topmortarseller/widget/auth/auth_form.dart';
import 'package:topmortarseller/widget/auth/auth_header.dart';
import 'package:topmortarseller/util/colors/color.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key, this.authType = AuthType.login});

  final AuthType authType;

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: SizedBox(
            height: MediaQuery.of(context).size.height,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AuthHeaderWidget(authType: widget.authType),
                const SizedBox(height: 48),
                AuthFormWidget(authType: widget.authType),
                Hero(
                  tag: AuthTagHero.dividerAuth,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: widget.authType == AuthType.login
                        ? const Divider(color: cDark600)
                        : Container(),
                  ),
                ),
                AuthFooterWidget(authType: widget.authType),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
