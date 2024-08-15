import 'package:flutter/material.dart';
import 'package:topmortarseller/util/enum.dart';
import 'package:topmortarseller/model/auth_settings_model.dart';
import 'package:topmortarseller/util/colors/color.dart';

class AuthFooterWidget extends StatefulWidget {
  const AuthFooterWidget({super.key, this.authType = AuthType.login});

  final AuthType authType;

  @override
  State<AuthFooterWidget> createState() => _AuthFooterWidgetState();
}

class _AuthFooterWidgetState extends State<AuthFooterWidget> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 48),
        Hero(
          tag: TagHero.copyrightAuth,
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
