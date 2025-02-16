import 'package:flutter/material.dart';
import 'package:topmortarseller/model/claimed_model.dart';
import 'package:topmortarseller/model/contact_model.dart';
import 'package:topmortarseller/model/customer_bank_model.dart';
import 'package:topmortarseller/services/claim_api.dart';
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
  List<ClaimedModel>? myRedeems = [];
  String? title;
  String? description;
  int totalQuota = 0;
  bool isLoading = true;

  @override
  void initState() {
    _getUserData();
    super.initState();
  }

  void _getUserData() async {
    setState(() => isLoading = true);

    // // final data = widget.userData ?? await getContactModel();
    final data = await getContactModel();
    setState(() {
      _userData = data;

      if (data != null) {
        if (data.nama != null && data.nama != null && data.nama!.isNotEmpty) {
          title = data.nama!;
        }
        if (data.address != null && data.address!.isNotEmpty) {
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
    final data = await ClaimCashbackServices().claimed(
      idContact: _userData!.idContact!,
      onSuccess: (msg) => null,
      onError: (e) {
        if (e != 'Tidak ada data') {
          showSnackBar(context, e);
        }
      },
      onCompleted: (apiResponse) {
        setState(() {
          if (apiResponse!.quota != null &&
              int.tryParse(apiResponse.quota!) != null) {
            totalQuota = int.parse(apiResponse.quota ?? '0');
          }
          isLoading = false;
        });
      },
    );
    setState(() {
      myRedeems = data;
    });
  }

  String _monthName(int month) {
    // List nama bulan dalam bahasa Indonesia
    List<String> months = [
      "Januari",
      "Februari",
      "Maret",
      "April",
      "Mei",
      "Juni",
      "Juli",
      "Agustus",
      "September",
      "Oktober",
      "November",
      "Desember"
    ];
    return months[month - 1];
  }

  String _formattedDate(dateString) {
    DateTime dateTime = DateTime.parse(dateString);
    String day = dateTime.day.toString().padLeft(2, '0');
    String month = _monthName(dateTime.month);
    String year = dateTime.year.toString();
    String hour = dateTime.hour.toString().padLeft(2, '0');
    String minute = dateTime.minute.toString().padLeft(2, '0');

    return "$day $month $year, $hour:$minute";
  }

  @override
  Widget build(BuildContext context) {
    Widget cardBank = Container();
    Widget emptyCardBank = Container();
    Widget aboutRedeem = Container();
    Widget redeemList = Container();
    Widget emptyRedeemList = Container();

    // final quotaPriority = _userData!.quotaPriority;
    var availableQuota = 0;

    if (myBanks != null && myBanks!.isNotEmpty) {
      cardBank = CardRekening(
        bankName: myBanks![0].namaBank!,
        rekening: myBanks![0].toAccount!,
        rekeningName: myBanks![0].toName!,
        badge: 'default',
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

      if (myRedeems != null && myRedeems!.isNotEmpty) {
        availableQuota = totalQuota - myRedeems!.length;
        redeemList = Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(0),
            itemCount: myRedeems!.length,
            itemBuilder: (context, i) {
              final redeemItem = myRedeems![i];
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
                          redeemItem.nama ?? 'null',
                          softWrap: true,
                          overflow: TextOverflow.visible,
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                        Text(
                          _formattedDate(redeemItem.claimDate!),
                          softWrap: true,
                          overflow: TextOverflow.visible,
                          style:
                              Theme.of(context).textTheme.bodyMedium!.copyWith(
                                    fontStyle: FontStyle.italic,
                                    color: cDark200,
                                  ),
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

      aboutRedeem = Container(
        color: cDark500,
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        child: Text(
          'Informasi Penukaran ($availableQuota kuota tersisa)',
          style: Theme.of(context)
              .textTheme
              .titleSmall!
              .copyWith(fontWeight: FontWeight.bold),
        ),
      );
    }

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
            const SizedBox(height: 24),
          ],
        ),
      );
    }

    if (myRedeems == null || myRedeems!.isEmpty) {
      emptyRedeemList = const SizedBox(
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 24),
            Text('Riwayat penukaran anda akan ditampilkan disini.'),
            SizedBox(height: 24),
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
                    emptyRedeemList,
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
        crossAxisAlignment: CrossAxisAlignment.start,
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
          Row(
            children: [
              const SizedBox(width: 24),
              const Hero(
                tag: TagHero.mainDrawerHeader,
                child: Icon(
                  Icons.storefront,
                  size: 24,
                  color: cWhite,
                ),
              ),
              const SizedBox(width: 12),
              title == null
                  ? const Expanded(
                      child: LoadingItem(
                        isPrimaryTheme: true,
                      ),
                    )
                  : Text(
                      title!,
                      style: Theme.of(context).textTheme.titleMedium!.copyWith(
                            color: cWhite,
                          ),
                    ),
              const SizedBox(width: 24),
            ],
          ),
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: description == null
                ? const LoadingItem(
                    isPrimaryTheme: true,
                  )
                : Text(
                    description!,
                    softWrap: true,
                    overflow: TextOverflow.visible,
                    style: Theme.of(context).textTheme.bodySmall!.copyWith(
                          color: cPrimary600,
                        ),
                  ),
          )
        ],
      ),
    );
  }
}
