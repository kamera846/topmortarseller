import 'package:flutter/material.dart';
import 'package:topmortarseller/model/contact_model.dart';
import 'package:topmortarseller/model/customer_bank_model.dart';
import 'package:topmortarseller/services/customer_bank_api.dart';
import 'package:topmortarseller/util/enum.dart';
import 'package:topmortarseller/screen/profile/new_rekening_screen.dart';
import 'package:topmortarseller/util/colors/color.dart';
import 'package:topmortarseller/util/loading_item.dart';
import 'package:topmortarseller/widget/card/rekening_card.dart';
import 'package:topmortarseller/widget/form/button/elevated_button.dart';
import 'package:topmortarseller/widget/modal/loading_modal.dart';
import 'package:topmortarseller/widget/snackbar/show_snackbar.dart';

class DetailProfileScreen extends StatefulWidget {
  const DetailProfileScreen({
    super.key,
    this.userData,
  });

  final ContactModel? userData;

  @override
  State<DetailProfileScreen> createState() => _DetailProfileScreenState();
}

class _DetailProfileScreenState extends State<DetailProfileScreen> {
  ContactModel? _userData;
  List<CustomerBankModel>? myBanks = [];
  String? title;
  String? description;
  bool isLoading = true;

  @override
  void initState() {
    _getUserData();
    super.initState();
  }

  void _getUserData() async {
    setState(() => isLoading = true);

    final data = widget.userData ?? await getContactModel();
    setState(() {
      _userData = data;

      if (data != null) {
        if (data.nama != null && data.nama != null && data.nama!.isNotEmpty) {
          title = data.nama!;
        }
        if (data.address != null &&
            data.address != null &&
            data.address!.isNotEmpty) {
          description = data.address!;
        } else if (data.nomorhp != null &&
            data.nomorhp != null &&
            data.nomorhp!.isNotEmpty) {
          description = data.nomorhp!;
        }
      }
    });

    _getUserBanks();
  }

  void _getUserBanks() async {
    final data = await CustomerBankApiService().banks(
      idContact: _userData!.idContact!,
      onSuccess: (msg) => null,
      onError: (e) => showSnackBar(context, e),
      onCompleted: () => setState(() => isLoading = false),
    );
    setState(() {
      myBanks = data;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Column(
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
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      if (myBanks != null && myBanks!.isNotEmpty)
                        Expanded(
                          child: ListView.builder(
                            padding: const EdgeInsets.all(0),
                            itemCount: myBanks!.length,
                            itemBuilder: (context, i) {
                              final bankItem = myBanks![i];
                              return RekeningCard(
                                bankName: bankItem.namaBank!,
                                rekening: bankItem.toAccount!,
                                rekeningName: bankItem.toName!,
                                rightIcon: Icons.edit_square,
                                action: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const NewRekeningScreen(),
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                        ),
                      if (myBanks == null || myBanks!.isEmpty)
                        SizedBox(
                          width: double.infinity,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const SizedBox(height: 24),
                              const Text('Anda belum menambahkan rekening!'),
                              const SizedBox(height: 12),
                              MElevatedButton(
                                title: 'Tambah Rekening',
                                onPressed: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const NewRekeningScreen(),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              // Container(
              //   padding: const EdgeInsets.all(12),
              //   child: MElevatedButton(
              //     title: 'Tambah Rekening Lain',
              //     isFullWidth: true,
              //     onPressed: () {
              //       Navigator.of(context).push(
              //         MaterialPageRoute(
              //           builder: (context) => const NewRekeningScreen(),
              //         ),
              //       );
              //     },
              //   ),
              // )
            ],
          ),
          if (isLoading) const LoadingModal()
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

  final String? title;
  final String? description;

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
              const SizedBox(width: 6),
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
              const SizedBox(width: 12),
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
                      title == null
                          ? const LoadingItem(
                              isPrimaryTheme: true,
                            )
                          : Text(
                              title!,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium!
                                  .copyWith(
                                    color: cWhite,
                                  ),
                            ),
                      description == null
                          ? const LoadingItem(
                              isPrimaryTheme: true,
                            )
                          : Text(
                              description!,
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
    );
  }
}
