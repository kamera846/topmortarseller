import 'package:flutter/material.dart';
import 'package:topmortarseller/model/contact_model.dart';
import 'package:topmortarseller/model/customer_bank_model.dart';
import 'package:topmortarseller/services/customer_bank_api.dart';
import 'package:topmortarseller/util/enum.dart';
import 'package:topmortarseller/screen/profile/new_rekening_screen.dart';
import 'package:topmortarseller/util/colors/color.dart';
import 'package:topmortarseller/util/loading_item.dart';
import 'package:topmortarseller/widget/card/card_rekening.dart';
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
  List<CustomerBankModel>? myRedeems = [];
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
      onCompleted: () => _getUserRedeemList(),
    );
    setState(() {
      myBanks = data;
    });
  }

  void _getUserRedeemList() async {
    final data = await CustomerBankApiService().banks(
      idContact: _userData!.idContact!,
      onSuccess: (msg) => null,
      onError: (e) => showSnackBar(context, e),
      onCompleted: () => setState(() => isLoading = false),
    );
    setState(() {
      myRedeems?.add(data![0]);
      myRedeems?.add(data![0]);
      myRedeems?.add(data![0]);
      myRedeems?.add(data![0]);
      myRedeems?.add(data![0]);
      myRedeems?.add(data![0]);
      myRedeems?.add(data![0]);
      myRedeems?.add(data![0]);
      myRedeems?.add(data![0]);
      myRedeems?.add(data![0]);
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget cardBank = Container();
    Widget aboutRedeem = Container();
    Widget redeemList = Container();
    if (myBanks != null && myBanks!.isNotEmpty) {
      cardBank = CardRekening(
        bankName: myBanks![0].namaBank!,
        rekening: myBanks![0].toAccount!,
        rekeningName: myBanks![0].toName!,
        rightIcon: Icons.mode_edit,
        action: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => NewRekeningScreen(
                userData: _userData,
                rekeningId: myBanks![0].idRekeningToko!,
                onSuccess: (bool? state) {
                  if (state != null && state) {
                    setState(() => isLoading = true);
                    _getUserBanks();
                  }
                },
              ),
            ),
          );
        },
      );

      aboutRedeem = Container(
        color: cDark500,
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        child: Text(
          'Informasi Penukaran',
          style: Theme.of(context)
              .textTheme
              .titleSmall!
              .copyWith(fontWeight: FontWeight.bold),
        ),
      );

      if (myRedeems != null && myRedeems!.isNotEmpty) {
        redeemList = Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(0),
            itemCount: myRedeems!.length,
            itemBuilder: (context, i) {
              final bankItem = myRedeems![i];
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    width: double.infinity,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Tukang Rafli Ramadani',
                          softWrap: true,
                          overflow: TextOverflow.visible,
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                        Text(
                          '06 September 2024',
                          softWrap: true,
                          overflow: TextOverflow.visible,
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium!
                              .copyWith(fontStyle: FontStyle.italic),
                        ),
                      ],
                    ),
                  ),
                  const Divider(
                    height: 1,
                    color: cDark500,
                  ),
                ],
              );
            },
          ),
        );
      }
    }
    Widget emptyCardBank = Container();
    if (myBanks == null || myBanks!.isEmpty) {
      emptyCardBank = SizedBox(
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
                    builder: (context) => NewRekeningScreen(
                      userData: _userData,
                      onSuccess: (bool? state) {},
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      );
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
            child: Stack(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(
                          top: 24, right: 24, left: 24, bottom: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Daftar Rekening',
                            style: Theme.of(context)
                                .textTheme
                                .titleSmall!
                                .copyWith(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            'Digunakan untuk tujuan transfer promo cashback dari kami.',
                            softWrap: true,
                            overflow: TextOverflow.visible,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          const SizedBox(height: 12),
                          cardBank,
                          emptyCardBank
                        ],
                      ),
                    ),
                    aboutRedeem,
                    redeemList,
                    // Expanded(
                    //   child: ListView.builder(
                    //     padding: const EdgeInsets.all(0),
                    //     itemCount: myBanks!.length,
                    //     itemBuilder: (context, i) {
                    //       final bankItem = myBanks![i];
                    //       return CardRekening(
                    //         bankName: bankItem.namaBank!,
                    //         rekening: bankItem.toAccount!,
                    //         rekeningName: bankItem.toName!,
                    //         rightIcon: Icons.mode_edit,
                    //         action: () {
                    //           Navigator.of(context).push(
                    //             MaterialPageRoute(
                    //               builder: (context) => NewRekeningScreen(
                    //                 userData: _userData,
                    //                 rekeningId: bankItem.idRekeningToko!,
                    //                 onSuccess: (bool? state) {
                    //                   if (state != null && state) {
                    //                     setState(() => isLoading = true);
                    //                     _getUserBanks();
                    //                   }
                    //                 },
                    //               ),
                    //             ),
                    //           );
                    //         },
                    //       );
                    //     },
                    //   ),
                    // ),
                  ],
                ),
                if (isLoading) const LoadingModal()
              ],
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
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            cPrimary100,
            cPrimary200,
            cPrimary100,
            cPrimary200,
            cPrimary100,
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
