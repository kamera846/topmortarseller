import 'package:flutter/material.dart';
import 'package:topmortarseller/data/auth_settings.dart';
import 'package:topmortarseller/model/auth_settings_model.dart';
import 'package:topmortarseller/screen/auth_screen.dart';
import 'package:topmortarseller/util/colors/color.dart';
import 'package:topmortarseller/widget/form/button/outlined_button.dart';

class AuthFooterWidget extends StatefulWidget {
  const AuthFooterWidget({super.key, this.authType = AuthType.login});

  final AuthType authType;

  @override
  State<AuthFooterWidget> createState() => _AuthFooterWidgetState();
}

class _AuthFooterWidgetState extends State<AuthFooterWidget> {
  void _outlinedButtonAction() {
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

  @override
  Widget build(BuildContext context) {
    final String? outlinedButtonDescription =
        authSettings[widget.authType]!.outlinedButtonDescription;
    final String? outlinedButtonText =
        authSettings[widget.authType]!.outlinedButtonText;

    return Column(
      children: [
        Hero(
          tag: AuthTagHero.outlinedButtonContainerAuth,
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
        const SizedBox(height: 48),
        Hero(
          tag: AuthTagHero.copyrightAuth,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Copyright ',
                style: Theme.of(context).textTheme.bodySmall!.copyWith(
                      color: cDark300,
                    ),
              ),
              const Icon(
                Icons.copyright,
                color: cDark300,
                size: 12,
              ),
              Text(
                ' 2024 Top Mortar Seller',
                style: Theme.of(context).textTheme.bodySmall!.copyWith(
                      color: cDark300,
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
