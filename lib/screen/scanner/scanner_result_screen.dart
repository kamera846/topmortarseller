import 'package:flutter/material.dart';
import 'package:topmortarseller/util/colors/color.dart';
import 'package:topmortarseller/widget/card/rekening_card.dart';
import 'package:topmortarseller/widget/form/button/elevated_button.dart';

class ScannerResultScreen extends StatefulWidget {
  const ScannerResultScreen({super.key});

  @override
  State<ScannerResultScreen> createState() {
    return _ScannerResultScreenState();
  }
}

class _ScannerResultScreenState extends State<ScannerResultScreen> {
  int selectedPosition = -1;

  @override
  Widget build(BuildContext context) {
    List<Widget> cards = [];
    for (var i = 0; i < 5; i++) {
      cards.add(
        RekeningCard(
          bankName: 'PT. BCA (Bank Central Asia) TBK',
          rekening: '0918230981283',
          rekeningName: 'a.n Mochammad Rafli Ramadani',
          backgroundColor: i == selectedPosition ? cPrimary600 : cWhite,
          withDeleteAction: false,
          action: () {
            setState(() {
              selectedPosition = i;
            });
          },
        ),
      );
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
          child: SingleChildScrollView(
            child: Column(
              children: cards,
            ),
          ),
        ),
        MElevatedButton(
          title: 'Lanjutkan',
          isFullWidth: true,
          enabled: selectedPosition != -1 ? true : false,
          onPressed: () {
            Navigator.of(context).pop();
            Navigator.of(context).pop();
          },
        )
      ]),
    );
  }
}
