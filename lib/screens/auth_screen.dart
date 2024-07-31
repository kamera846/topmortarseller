import 'package:flutter/material.dart';
import 'package:topmortarseller/data/auth_settings.dart';
import 'package:topmortarseller/models/auth_settings_model.dart';
import 'package:topmortarseller/util/validator/validator.dart';
import 'package:topmortarseller/widget/form/textfield/text_field.dart';
import 'package:topmortarseller/util/colors/color.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key, this.authType = AuthType.login});

  final AuthType authType;

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool _isPasswordHidden = true;

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
                Hero(
                  tag: AuthTagHero.faviconAuth,
                  child: Image.asset(
                    'assets/favicon/favicon_circle.png',
                    width: 100,
                  ),
                ),
                const SizedBox(height: 12),
                Hero(
                  tag: AuthTagHero.titleAuth,
                  child: Text(
                    authSettings[widget.authType]!.title,
                    style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                          color: cDark100,
                        ),
                  ),
                ),
                const SizedBox(height: 6),
                Hero(
                  tag: AuthTagHero.descriptionAuth,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Text(
                      authSettings[widget.authType]!.description,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                            color: cDark300,
                          ),
                    ),
                  ),
                ),
                const SizedBox(height: 48),
                MTextField(
                  label: 'Nomor Telpon',
                  inputAction: TextInputAction.next,
                  prefixIcon: Icons.phone,
                  keyboardType: TextInputType.phone,
                  validator: Validator.number,
                  onChanged: (value) {},
                ),
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
                            style:
                                Theme.of(context).textTheme.bodySmall!.copyWith(
                                      color: cDark300,
                                    ),
                          ),
                        ),
                      )
                    : Container(),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: cPrimary100,
                    foregroundColor: cWhite,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width,
                    child: Text(
                      authSettings[widget.authType]!.elevatedButtonText,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleMedium!.copyWith(
                            color: cWhite,
                          ),
                    ),
                  ),
                ),
                widget.authType == AuthType.login
                    ? const SizedBox(height: 8)
                    : Container(),
                widget.authType == AuthType.login
                    ? Hero(
                        tag: AuthTagHero.forgotButtonAuth,
                        child: TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (ctx) => const AuthScreen(
                                  authType: AuthType.forgot,
                                ),
                              ),
                            );
                          },
                          child: Text(
                            'Lupa Kata Sandi',
                            style: Theme.of(context)
                                .textTheme
                                .titleSmall!
                                .copyWith(
                                  color: cPrimary300,
                                ),
                          ),
                        ),
                      )
                    : Container(),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: widget.authType == AuthType.login
                      ? const Divider(color: cDark600)
                      : Container(),
                ),
                Hero(
                  tag: AuthTagHero.outlinedButtonContainer,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        authSettings[widget.authType]!
                            .outlinedButtonDescription,
                        style: Theme.of(context).textTheme.bodySmall!.copyWith(
                              color: cDark300,
                            ),
                      ),
                      const SizedBox(width: 8),
                      OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: cPrimary100,
                          side: const BorderSide(color: cDark600),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () {
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
                        },
                        child: Text(
                          authSettings[widget.authType]!.outlinedButtonText,
                          style:
                              Theme.of(context).textTheme.bodySmall!.copyWith(
                                    color: cPrimary100,
                                  ),
                        ),
                      ),
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
                              color: cDark600,
                            ),
                      ),
                      const Icon(
                        Icons.copyright,
                        color: cDark600,
                        size: 12,
                      ),
                      Text(
                        ' 2024 Top Mortar Seller',
                        style: Theme.of(context).textTheme.bodySmall!.copyWith(
                              color: cDark600,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
