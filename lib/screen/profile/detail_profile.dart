import 'package:flutter/material.dart';
import 'package:topmortarseller/data/tag_hero.dart';
import 'package:topmortarseller/util/colors/color.dart';
import 'package:topmortarseller/widget/card/rekening_card.dart';
import 'package:topmortarseller/widget/form/button/elevated_button.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 12,
              right: 0,
              bottom: 12,
              left: 0,
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  cPrimary100,
                  cPrimary100.withOpacity(0.8),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    const SizedBox(width: 12),
                    IconButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      style: IconButton.styleFrom(
                        padding: const EdgeInsets.all(1),
                      ),
                      icon: const Icon(
                        Icons.arrow_back,
                        color: cWhite,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Profil Saya',
                      style: Theme.of(context).textTheme.titleMedium!.copyWith(
                            color: cWhite,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Hero(
                  tag: TagHero.mainDrawerHeader,
                  child: Row(
                    children: [
                      const SizedBox(width: 12),
                      const Icon(
                        Icons.storefront,
                        size: 48,
                        color: cWhite,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Toko Barokah Jaya',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium!
                                  .copyWith(
                                    color: cWhite,
                                  ),
                            ),
                            Text(
                              'Jl Anggrek 3 asrikaton kec. pakis kab. malang',
                              softWrap: true,
                              overflow: TextOverflow.visible,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall!
                                  .copyWith(
                                    color: cPrimary600,
                                  ),
                            )
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Daftar Rekening',
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      Text(
                          'Digunakan untuk tujuan transfer promo cashback dari kami.',
                          softWrap: true,
                          overflow: TextOverflow.visible,
                          style: Theme.of(context).textTheme.bodySmall)
                    ],
                  ),
                  const SizedBox(height: 12),
                  const RekeningCard(),
                  const RekeningCard(),
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(12),
            child: MElevatedButton(
              title: 'Tambah Rekening Lain',
              isFullWidth: true,
              onPressed: () {},
            ),
          )
        ],
      ),
    );
  }
}
