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
import 'package:topmortarseller/util/phone_format.dart';
import 'package:topmortarseller/widget/card/card_rekening.dart';
import 'package:topmortarseller/widget/form/button/elevated_button.dart';
import 'package:topmortarseller/widget/snackbar/show_snackbar.dart';

class DetailProfileScreen extends StatefulWidget {
  const DetailProfileScreen({super.key, this.userData});

  final ContactModel? userData;

  @override
  State<DetailProfileScreen> createState() => _DetailProfileScreenState();
}

class _DetailProfileScreenState extends State<DetailProfileScreen> {
  ContactModel? _userData;
  List<CustomerBankModel>? myBanks = [];
  List<ClaimedModel>? myRedeems = [];
  String? title;
  String? phone;
  String? description;
  int totalQuota = 0;
  bool isLoading = true;
  bool isLoadingRedeem = true;

  @override
  void initState() {
    super.initState();
    _getUserData();
  }

  void _getUserData() async {
    setState(() => isLoading = true);

    final data = widget.userData ?? await getContactModel();
    // final data = await getContactModel();
    setState(() {
      _userData = data;

      if (data != null) {
        if (data.nama != null && data.nama!.isNotEmpty) {
          title = data.nama!;
        }
        if (data.nomorhp != null && data.nomorhp!.isNotEmpty) {
          phone = data.nomorhp!;
        }
        if (data.address != null && data.address!.isNotEmpty) {
          description = data.address!;
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

  Future<void> _getUserRedeemList() async {
    setState(() {
      isLoadingRedeem = true;
    });
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
      isLoadingRedeem = false;
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
      "Desember",
    ];
    return months[month - 1];
  }

  String _formattedDate(String dateString) {
    try {
      DateTime dateTime = DateTime.parse(dateString);
      String day = dateTime.day.toString().padLeft(2, '0');
      String month = _monthName(dateTime.month);
      String year = dateTime.year.toString();
      String hour = dateTime.hour.toString().padLeft(2, '0');
      String minute = dateTime.minute.toString().padLeft(2, '0');

      return "$day $month $year, $hour:$minute";
    } catch (e) {
      return dateString;
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget cardBank = Container();
    Widget emptyCardBank = Container();
    Widget aboutRedeem = Container();
    Widget redeemList = Container();
    Widget emptyRedeemList = Container();

    // final quotaPriority = _userData!.quotaPriority;
    var availableQuota = totalQuota;

    if (myRedeems != null && myRedeems!.isNotEmpty) {
      availableQuota = totalQuota - myRedeems!.length;
    }

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
        redeemList = Expanded(
          child: isLoadingRedeem
              ? Center(child: CircularProgressIndicator.adaptive())
              : RefreshIndicator.adaptive(
                  onRefresh: () => _getUserRedeemList(),
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
                                  _formattedDate(redeemItem.claimDate ?? '-'),
                                  softWrap: true,
                                  overflow: TextOverflow.visible,
                                  style: Theme.of(context).textTheme.bodyMedium!
                                      .copyWith(
                                        fontStyle: FontStyle.italic,
                                        color: cDark200,
                                      ),
                                ),
                              ],
                            ),
                          ),
                          const Divider(height: 1, color: cDark500),
                        ],
                      );
                    },
                  ),
                ),
        );
      }

      aboutRedeem = Container(
        color: cDark500,
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        child: Text(
          'Penukaran Voucher ($availableQuota kuota tersisa)',
          style: Theme.of(
            context,
          ).textTheme.titleSmall!.copyWith(fontWeight: FontWeight.bold),
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
      backgroundColor: Colors.transparent,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(24),
            child: DetailProfileHeader(
              title: title,
              phone: phone,
              description: description,
            ),
          ),
          Expanded(
            child: Material(
              color: cWhite,
              child: isLoading
                  ? const Center(child: CircularProgressIndicator.adaptive())
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(
                            left: 16,
                            top: 16,
                            right: 16,
                            bottom: 16,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Daftar Rekening',
                                style: Theme.of(context).textTheme.titleMedium!
                                    .copyWith(fontWeight: FontWeight.bold),
                              ),
                              Text(
                                'Digunakan untuk tujuan transfer promo cashback dari kami.',
                                softWrap: true,
                                overflow: TextOverflow.visible,
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                              const SizedBox(height: 16),
                              cardBank,
                              emptyCardBank,
                            ],
                          ),
                        ),
                        aboutRedeem,
                        redeemList,
                        emptyRedeemList,
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class DetailProfileHeader extends StatelessWidget {
  const DetailProfileHeader({
    super.key,
    required this.title,
    required this.phone,
    required this.description,
  });

  final String? title;
  final String? phone;
  final String? description;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Hero(
              tag: TagHero.mainDrawerHeader,
              child: Icon(Icons.storefront, size: 24, color: cWhite),
            ),
            const SizedBox(width: 12),
            title == null
                ? const Expanded(child: LoadingItem(isPrimaryTheme: true))
                : Text(
                    title!,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.normal,
                      fontSize: 20,
                    ),
                  ),
          ],
        ),
        const SizedBox(height: 6),
        phone == null
            ? const LoadingItem(isPrimaryTheme: true)
            : Text(
                MyPhoneFormat.format(phone!),
                softWrap: true,
                overflow: TextOverflow.visible,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium!.copyWith(color: cWhite),
              ),
        description == null
            ? const LoadingItem(isPrimaryTheme: true)
            : Text(
                description!,
                softWrap: true,
                overflow: TextOverflow.visible,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium!.copyWith(color: cWhite),
              ),
      ],
    );
  }
}
