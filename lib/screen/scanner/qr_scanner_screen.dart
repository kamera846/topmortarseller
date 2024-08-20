import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:topmortarseller/model/contact_model.dart';
import 'package:topmortarseller/model/customer_bank_model.dart';
import 'package:topmortarseller/screen/scanner/scanner_result_screen.dart';
import 'package:topmortarseller/services/claim_api.dart';
import 'package:topmortarseller/util/enum.dart';
import 'package:topmortarseller/util/colors/color.dart';
import 'package:topmortarseller/widget/modal/info_modal.dart';
import 'package:topmortarseller/widget/modal/loading_modal.dart';

class QRScannerScreen extends StatefulWidget {
  const QRScannerScreen({
    super.key,
    this.userData,
  });

  final ContactModel? userData;

  @override
  State<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  ContactModel? _userData;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? qrController;
  String? scanResult;
  bool isLoading = false;
  bool isScanResultFounded = false;

  @override
  void initState() {
    _getUserData();
    super.initState();
  }

  void _getUserData() async {
    final data = widget.userData ?? await getContactModel();
    setState(() {
      _userData = data;
    });
  }

  @override
  void reassemble() {
    super.reassemble();
    if (qrController != null) {
      if (Platform.isAndroid) {
        qrController!.pauseCamera();
      }
      qrController!.resumeCamera();
    }
  }

  void _onQRViewCreated(QRViewController controller) {
    setState(() {
      qrController = controller;
    });
    qrController!.scannedDataStream.listen((scanData) {
      if (!isScanResultFounded) {
        setState(() {
          isScanResultFounded = true;
          scanResult = scanData.code;
        });
        showScannerResultScreen();
        return;
      }
    });
  }

  void _processedClaim(CustomerBankModel bank) async {
    setState(() => isLoading = true);
    await ClaimCashbackServices().claim(
      idContact: _userData!.idContact!,
      idMd5: scanResult!,
      onSuccess: (msg) async {
        await showCupertinoDialog(
          context: context,
          builder: (context) {
            return MInfoModal(
              contentName: 'Berhasil Klaim',
              contentDescription: msg,
              contentIcon: Icons.change_circle_rounded,
              contentIconColor: Colors.green.shade800,
              cancelText: null,
              onConfirm: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
            );
          },
        );
        setState(() {
          isScanResultFounded = false;
        });
        qrController!.resumeCamera();
      },
      onError: (e) async {
        await showCupertinoDialog(
          context: context,
          builder: (context) {
            return MInfoModal(
              contentName: 'Gagal Klaim',
              contentDescription: e,
              contentIcon: Icons.warning_rounded,
              contentIconColor: cPrimary100,
              cancelText: null,
              onConfirm: () {
                Navigator.of(context).pop();
                setState(() {
                  isScanResultFounded = false;
                });
                qrController!.resumeCamera();
              },
            );
          },
        );
        setState(() {
          isScanResultFounded = false;
        });
        qrController!.resumeCamera();
      },
      onCompleted: () {
        setState(() => isLoading = false);
      },
    );
  }

  void showScannerResultScreen() async {
    qrController!.pauseCamera();
    CustomerBankModel? selectedBank;
    await showModalBottomSheet(
      barrierColor: cDark100.withOpacity(0.7),
      context: context,
      builder: (ctx) => ScannerResultScreen(
        userData: _userData,
        scanResult: scanResult,
        onProcessedClaim: (bank) {
          selectedBank = bank;
        },
      ),
    );
    if (selectedBank != null) {
      _processedClaim(selectedBank!);
    } else {
      setState(() {
        isScanResultFounded = false;
      });
      qrController!.resumeCamera();
    }
  }

  @override
  void dispose() {
    qrController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          QRView(
            key: qrKey,
            onQRViewCreated: _onQRViewCreated,
            overlay: QrScannerOverlayShape(
              borderColor: cPrimary100,
              borderRadius: 10,
              borderLength: 50,
              borderWidth: 10,
              cutOutSize: MediaQuery.of(context).size.width * 0.8,
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).padding.top + 24,
            left: 24,
            right: 24,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  icon: const Icon(
                    Icons.arrow_back_ios_rounded,
                    color: cWhite,
                  ),
                ),
                Text(
                  'Top Mortar Scanner',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium!
                      .copyWith(color: cWhite),
                ),
                Hero(
                  tag: TagHero.faviconAuth,
                  child: Semantics(
                    label: '${TagHero.faviconAuth}',
                    child: Image.asset(
                      'assets/favicon/favicon_circle.png',
                      width: 32,
                    ),
                  ),
                )
              ],
            ),
          ),
          if (isLoading) const LoadingModal()
        ],
      ),
    );
  }
}
