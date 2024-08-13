// ignore_for_file: use_build_context_synchronously

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:topmortarseller/model/contact_model.dart';
import 'package:topmortarseller/screen/auth_screen.dart';
import 'package:topmortarseller/screen/profile/detail_profile_screen.dart';
import 'package:topmortarseller/util/auth_settings.dart';
import 'package:topmortarseller/util/colors/color.dart';
import 'package:topmortarseller/widget/modal/info_modal.dart';

class MainDrawerItems extends StatelessWidget {
  const MainDrawerItems({
    super.key,
    this.userData,
  });

  final ContactModel? userData;

  void _showConfirmlogout(BuildContext context) {
    showCupertinoDialog(
      context: context,
      builder: (BuildContext context) {
        return MInfoModal(
          contentName: 'Keluar dari akun?',
          contentDescription:
              'Anda diharuskan login kembali ketika mengakses aplikasi jika keluar dari akun.',
          contentIcon: Icons.warning_rounded,
          contentIconColor: cPrimary100,
          cancelText: 'Batal',
          onCancel: () {
            Navigator.of(context).pop();
          },
          confirmText: 'Oke',
          onConfirm: () async {
            await removeLoginState();
            await removeContactModel();
            Navigator.of(context).pop();
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (ctx) => const AuthScreen(),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          leading: const Icon(
            CupertinoIcons.person_crop_circle,
            size: 26,
            color: cDark100,
          ),
          title: Text(
            'Profil saya',
            style: Theme.of(context).textTheme.titleSmall!.copyWith(
                  color: cDark100,
                ),
          ),
          subtitle: Text(
            'Atur profil anda disini',
            style: Theme.of(context).textTheme.bodySmall!.copyWith(
                  color: cDark200,
                ),
          ),
          onTap: () {
            Navigator.of(context).pop();
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (ctx) => DetailProfileScreen(userData: userData),
              ),
            );
          },
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
          child: Divider(
            height: 1,
            color: cDark500,
          ),
        ),
        ListTile(
          leading: const Icon(
            CupertinoIcons.power,
            size: 26,
            color: cDark100,
          ),
          title: Text(
            'Keluar',
            style: Theme.of(context).textTheme.titleSmall!.copyWith(
                  color: cDark100,
                ),
          ),
          subtitle: Text(
            'Anda akan keluar dari akun saat ini',
            style: Theme.of(context).textTheme.bodySmall!.copyWith(
                  color: cDark200,
                ),
          ),
          onTap: () {
            Navigator.of(context).pop();
            _showConfirmlogout(context);
          },
        ),
      ],
    );
  }
}
