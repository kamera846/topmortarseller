import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:topmortarseller/screen/auth_screen.dart';
import 'package:topmortarseller/screen/profile/detail_profile_screen.dart';
import 'package:topmortarseller/util/colors/color.dart';

class MainDrawerItems extends StatelessWidget {
  const MainDrawerItems({super.key});

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
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (ctx) => const DetailProfileScreen(),
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
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (ctx) => const AuthScreen(),
              ),
            );
          },
        ),
      ],
    );
  }
}
