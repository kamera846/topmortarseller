import 'package:flutter/material.dart';
import 'package:topmortarseller/model/contact_model.dart';
import 'package:topmortarseller/util/enum.dart';
import 'package:topmortarseller/screen/profile/new_rekening_screen.dart';
import 'package:topmortarseller/util/colors/color.dart';
import 'package:topmortarseller/widget/card/rekening_card.dart';
import 'package:topmortarseller/widget/form/button/elevated_button.dart';

class DetailProfileScreen extends StatefulWidget {
  const DetailProfileScreen({super.key});

  @override
  State<DetailProfileScreen> createState() => _DetailProfileScreenState();
}

class _DetailProfileScreenState extends State<DetailProfileScreen> {
  late ContactModel? userData;

  @override
  void initState() {
    super.initState();
    _getUserData();
  }

  void _getUserData() async {
    final data = await getContactModel();
    setState(() {
      userData = data;
    });
  }

  @override
  Widget build(BuildContext context) {
    var title = '-';
    var description = '-';

    if (userData != null) {
      if (userData!.nama != null &&
          userData!.nama != null &&
          userData!.nama!.isNotEmpty) {
        title = userData!.nama!;
      }
      if (userData!.address != null &&
          userData!.address != null &&
          userData!.address!.isNotEmpty) {
        description = userData!.address!;
      } else if (userData!.nomorhp != null &&
          userData!.nomorhp != null &&
          userData!.nomorhp!.isNotEmpty) {
        description = userData!.nomorhp!;
      }
    }

    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DetailProfileHeader(
            title: title,
            description: description,
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 24,
              ),
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
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const NewRekeningScreen(),
                  ),
                );
              },
            ),
          )
        ],
      ),
    );
  }
}

class DetailProfileHeader extends StatelessWidget {
  const DetailProfileHeader({
    super.key,
    required this.title,
    required this.description,
  });

  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 12,
        right: 0,
        bottom: 24,
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
                  padding: const EdgeInsets.all(0),
                ),
                icon: const Icon(
                  Icons.arrow_back,
                  color: cWhite,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Profil Saya',
                style: Theme.of(context).textTheme.titleLarge!.copyWith(
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
                        title,
                        style:
                            Theme.of(context).textTheme.titleMedium!.copyWith(
                                  color: cWhite,
                                ),
                      ),
                      Text(
                        description,
                        softWrap: true,
                        overflow: TextOverflow.visible,
                        style: Theme.of(context).textTheme.bodySmall!.copyWith(
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
    );
  }
}
