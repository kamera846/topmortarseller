import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
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
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Konfirmasi rekening tujuan',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          const Expanded(
            child: SingleChildScrollView(
              child: Column(children: [
                RekeningCard(),
                RekeningCard(),
                RekeningCard(),
                RekeningCard(),
                RekeningCard(),
                RekeningCard(),
              ]),
            ),
          ),
          MElevatedButton(
            title: 'Lanjutkan',
            isFullWidth: true,
            onPressed: () {},
          )
        ],
      ),
    );
  }
}
