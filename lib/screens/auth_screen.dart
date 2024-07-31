import 'package:flutter/material.dart';
import 'package:topmortarseller/screens/splash_screen.dart';
import 'package:topmortarseller/util/validator/validator.dart';
import 'package:topmortarseller/widget/form/textfield/text_field.dart';
import 'package:topmortarseller/util/colors/color.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

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
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Hero(
                  tag: 'favicon-auth',
                  child: Image.asset(
                    'assets/favicon/favicon_circle.png',
                    width: 100,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Top Mortar Seller',
                  style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                        color: cDark100,
                      ),
                ),
                const SizedBox(height: 6),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Text(
                    'Gunakan akun yang terdaftar untuk melanjutkan.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                          color: cDark300,
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
                MTextField(
                  label: 'Password',
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
                            color: cDark300,
                          ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SplashScreen(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: cPrimary100,
                    foregroundColor: cWhite,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width,
                      child: Text(
                        'Masuk',
                        textAlign: TextAlign.center,
                        style:
                            Theme.of(context).textTheme.titleMedium!.copyWith(
                                  color: cWhite,
                                ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () {},
                  child: Text(
                    'Lupa Password',
                    style: Theme.of(context).textTheme.titleSmall!.copyWith(
                          color: cPrimary300,
                        ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Container(
                    height: 1,
                    decoration: const BoxDecoration(color: cDark600),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Belum punya akun?',
                      style: Theme.of(context).textTheme.bodySmall!.copyWith(
                            color: cDark300,
                          ),
                    ),
                    const SizedBox(width: 12),
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: cPrimary100,
                        side: const BorderSide(
                          color: cDark600,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {},
                      child: Text(
                        'Daftar Sekarang?',
                        style: Theme.of(context).textTheme.bodySmall!.copyWith(
                              color: cPrimary100,
                            ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 48),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Copyright ',
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall!
                          .copyWith(color: cDark600),
                    ),
                    const Icon(
                      Icons.copyright,
                      color: cDark600,
                      size: 12,
                    ),
                    Text(
                      ' 2024 Top Mortar Seller',
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall!
                          .copyWith(color: cDark600),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
