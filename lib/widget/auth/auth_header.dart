import 'package:flutter/material.dart';
import 'package:topmortarseller/util/auth_settings.dart';
import 'package:topmortarseller/util/enum.dart';
import 'package:topmortarseller/util/colors/color.dart';

class AuthHeaderWidget extends StatelessWidget {
  const AuthHeaderWidget({super.key, this.authType = AuthType.login});

  final AuthType authType;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: MediaQuery.of(context).padding.top,
        ),
        Hero(
          tag: TagHero.faviconAuth,
          child: Semantics(
            label: '${TagHero.faviconAuth}',
            child: Image.asset(
              'assets/favicon/favicon_circle.png',
              width: 100,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Hero(
          tag: TagHero.titleAuth,
          child: Text(
            authSettings[authType]!.title,
            style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                  color: cDark100,
                ),
          ),
        ),
        const SizedBox(height: 6),
        Hero(
          tag: TagHero.descriptionAuth,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              authSettings[authType]!.description,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                    color: cDark200,
                  ),
            ),
          ),
        ),
      ],
    );
  }
}
