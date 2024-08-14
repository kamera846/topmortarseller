import 'package:flutter/material.dart';
import 'package:topmortarseller/model/contact_model.dart';
import 'package:topmortarseller/model/customer_bank_model.dart';
import 'package:topmortarseller/services/customer_bank_api.dart';
import 'package:topmortarseller/util/colors/color.dart';
import 'package:topmortarseller/widget/card/rekening_card.dart';
import 'package:topmortarseller/widget/form/button/elevated_button.dart';
import 'package:topmortarseller/widget/modal/loading_modal.dart';
import 'package:topmortarseller/widget/snackbar/show_snackbar.dart';

class ScannerResultScreen extends StatefulWidget {
  const ScannerResultScreen(
      {super.key,
      this.userData,
      required this.scanResult,
      required this.onProcessedClaim});

  final ContactModel? userData;
  final String? scanResult;
  final Function(CustomerBankModel?) onProcessedClaim;

  @override
  State<ScannerResultScreen> createState() {
    return _ScannerResultScreenState();
  }
}

class _ScannerResultScreenState extends State<ScannerResultScreen> {
  int selectedPosition = -1;
  ContactModel? _userData;
  List<CustomerBankModel>? myBanks = [];
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
    Widget rekeningCards = Container();
    if (isLoading) {
      rekeningCards = const LoadingModal();
    } else {
      if (myBanks != null && myBanks!.isNotEmpty) {
        rekeningCards = ListView.builder(
          itemCount: myBanks!.length,
          itemBuilder: (context, index) {
            final bankItem = myBanks![index];
            return RekeningCard(
              bankName: bankItem.namaBank!,
              rekening: bankItem.toAccount!,
              rekeningName: bankItem.toName!,
              backgroundColor: index == selectedPosition ? cPrimary600 : cWhite,
              withDeleteAction: false,
              action: () {
                setState(() {
                  selectedPosition = index;
                });
              },
            );
          },
        );
      } else {
        rekeningCards = SizedBox(
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 24),
              const Text('Anda belum menambahkan rekening!'),
              const SizedBox(height: 12),
              MElevatedButton(
                title: 'Tambah Rekening',
                onPressed: () {},
              ),
            ],
          ),
        );
      }
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: const BoxDecoration(
        color: cWhite,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.drag_handle_rounded),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          'Konfirmasi Rekening',
          style: Theme.of(context).textTheme.titleMedium!.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        Text(
          'Cashback akan diteruskan ke rekening yang anda pilih',
          style: Theme.of(context).textTheme.bodySmall!,
        ),
        const SizedBox(height: 12),
        Expanded(
          child: rekeningCards,
        ),
        MElevatedButton(
          title: 'Lanjutkan',
          isFullWidth: true,
          enabled: selectedPosition != -1 ? true : false,
          onPressed: () {
            if (selectedPosition != -1) {
              widget.onProcessedClaim(myBanks![selectedPosition]);
              Navigator.pop(context);
            }
          },
        )
      ]),
    );
  }
}
