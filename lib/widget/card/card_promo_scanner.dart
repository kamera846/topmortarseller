import 'package:flutter/material.dart';
import 'package:topmortarseller/util/colors/color.dart';
import 'package:topmortarseller/screen/scanner/qr_scanner_screen.dart';

class HomeHeader extends StatefulWidget {
  const HomeHeader({super.key});

  @override
  State<HomeHeader> createState() => _HomeHeaderState();
}

class _HomeHeaderState extends State<HomeHeader> {
  String? _scanResult;

  void onScanResult(result) {
    setState(() {
      _scanResult = result;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      margin: const EdgeInsets.all(12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16), // Menentukan sudut melengkung
      ),
      child: Container(
        width: double.maxFinite,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              cPrimary100,
              cPrimary200,
              cPrimary100,
              cPrimary200,
              cPrimary100,
            ], // Warna gradasi
            begin: Alignment.topLeft, // Titik awal gradasi
            end: Alignment.bottomRight, // Titik akhir gradasi
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: cPrimary100,
                borderRadius: BorderRadius.all(
                  Radius.circular(80),
                ),
                boxShadow: [
                  BoxShadow(
                    color: cPrimary200, // Warna bayangan dengan transparansi
                    spreadRadius: 1, // Jarak penyebaran bayangan
                    blurRadius: 2, // Jarak kabur bayangan
                    offset: Offset(
                        1, 1.5), // Posisi bayangan (horizontal, vertikal)
                  ),
                ],
              ),
              child: const Icon(
                Icons.qr_code_rounded,
                color: cWhite,
                size: 75,
              ),
            ),
            const SizedBox(width: 24),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _scanResult ?? 'Promo tersedia',
                    style: Theme.of(context).textTheme.bodySmall!.copyWith(
                          color: cDark400,
                        ),
                  ),
                  Text(
                    'Ambil Cashback!',
                    style: Theme.of(context).textTheme.titleLarge!.copyWith(
                          color: cWhite,
                        ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.maxFinite,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: cPrimary600.withOpacity(0.5),
                        foregroundColor: Colors.white,
                        shape: ContinuousRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (ctx) => QRScannerScreen(
                              onScanResult: onScanResult,
                            ),
                          ),
                        );
                      },
                      child: const Text("Scan Sekarang"),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
