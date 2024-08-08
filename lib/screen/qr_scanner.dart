import 'dart:io';

import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:topmortarseller/util/tag_hero.dart';
import 'package:topmortarseller/util/colors/color.dart';

class QRScannerScreen extends StatefulWidget {
  const QRScannerScreen({super.key, required this.onScanResult});

  final Function(String? result) onScanResult;

  @override
  State<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? qrController;
  bool isScanResultFounded = false;

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
        });
        widget.onScanResult(scanData.code);
        qrController!.pauseCamera;
        print('QR Code Data: ${scanData.code}');
        Navigator.of(context).pop();
        return;
      }
    });
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
                  child: Image.asset(
                    'assets/favicon/favicon_circle.png',
                    width: 32,
                  ),
                )
              ],
            ),
          ),
          // Positioned(
          //   bottom: 24,
          //   left: 24,
          //   right: 24,
          //   child: ElevatedButton(
          //     onPressed: _pickFile,
          //     child: const Text('Unggah Gambar'),
          //   ),
          // ),
        ],
      ),
    );
  }
}
