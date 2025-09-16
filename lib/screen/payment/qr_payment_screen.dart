import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:media_store_plus/media_store_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:topmortarseller/util/colors/color.dart';
import 'package:topmortarseller/util/enum.dart';
import 'package:topmortarseller/widget/modal/modal_action.dart';

class QrPaymentScreen extends StatefulWidget {
  const QrPaymentScreen({super.key});

  @override
  State<QrPaymentScreen> createState() => _QrPaymentScreenState();
}

class _QrPaymentScreenState extends State<QrPaymentScreen> {
  final GlobalKey _qrisWrapper = GlobalKey();
  final String qrImageUrl =
      'https://dev-seller.topmortarindonesia.com/assets/img/qris_img/qris_11720_1757671472.png';

  // Contoh waktu kadaluarsa dalam detik (5 menit)
  final int _expiryDuration = 120;
  late int _remainingSeconds;
  Timer? _timer;

  bool isStartLoadQris = false;

  @override
  void initState() {
    super.initState();
    _onReload();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _onReload() {
    setState(() {
      isStartLoadQris = false;
    });
    _timer?.cancel();
    _remainingSeconds = _expiryDuration;
    _startTimer();
    Future.delayed(Duration(milliseconds: 500), () {
      setState(() {
        isStartLoadQris = true;
      });
    });
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() {
          _remainingSeconds--;
        });
      } else {
        _timer?.cancel();
        _showExpiredDialog();
      }
    });
  }

  void _showExpiredDialog() {
    showAdaptiveDialog(
      context: context,
      builder: (context) => AlertDialog.adaptive(
        title: const Text('QR Code Kadaluarsa'),
        content: const Text(
          'Silakan buat pembayaran baru untuk mendapatkan QR Code baru dan lanjutkan pembayaran anda kembali.',
        ),
        actions: [
          ModalAction.adaptiveAction(
            context: context,
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    ).then((value) {
      if (!mounted) return;
      Navigator.of(context).pop(PopValue.needRefresh);
    });
  }

  void _downloadQrCode() async {
    try {
      final granted = await requestStoragePermissions();
      if (!granted) {
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Izin penyimpanan ditolak")));
        return;
      }

      final renderObject = _qrisWrapper.currentContext?.findRenderObject();

      if (renderObject == null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Gagal mendapatkan ukuran qris untuk di download."),
          ),
        );
        return;
      }

      final boundary = renderObject as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData = await image.toByteData(
        format: ui.ImageByteFormat.png,
      );
      Uint8List pngBytes = byteData!.buffer.asUint8List();

      // Simpan byte ke file sementara
      final tempDir = await getTemporaryDirectory();
      final tempFilePath =
          '${tempDir.path}/qr_mytop_seller_invoice_123456_${DateTime.now().millisecondsSinceEpoch}.png';
      final tempFile = File(tempFilePath);
      await tempFile.writeAsBytes(pngBytes);

      final mediaStore = MediaStore();
      final result = await mediaStore.saveFile(
        tempFilePath: tempFilePath,
        dirType: DirType.download,
        dirName: DirName.download,
      );

      if (!mounted) return;

      if (result != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("QR Code berhasil disimpan ke galeri!")),
        );
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Gagal menyimpan QR Code")));
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Terjadi kesalahan saat menyimpan. Error: $e")),
      );
    }
  }

  Future<bool> requestStoragePermissions() async {
    if (Platform.isAndroid) {
      final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
      final AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;

      if (androidInfo.version.sdkInt >= 33) {
        final photosPermission = await Permission.photos.request();
        return photosPermission.isGranted;
      } else if (androidInfo.version.sdkInt >= 30) {
        return true;
      } else {
        final storagePermission = await Permission.storage.request();
        return storagePermission.isGranted;
      }
    } else if (Platform.isIOS) {
      final photosPermission = await Permission.photos.request();
      return photosPermission.isGranted;
    } else {
      return true;
    }
  }

  @override
  Widget build(BuildContext context) {
    String formattedTime = _formatTime(_remainingSeconds);
    return Scaffold(
      backgroundColor: cDark600,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Pembayaran QRIS'),
        centerTitle: false,
        backgroundColor: cWhite,
        foregroundColor: cDark100,
        scrolledUnderElevation: 0,
        shape: Border(bottom: BorderSide(color: cDark500)),
      ),
      body: SafeArea(
        child: RefreshIndicator.adaptive(
          onRefresh: () async => _onReload(),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                /// --- Timeout Section ---
                const Text(
                  'Scan QR Code di bawah ini untuk menyelesaikan pembayaran sebelum',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: cDark100),
                ),
                const SizedBox(height: 8),
                Text(
                  formattedTime,
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: _remainingSeconds < 60 ? cPrimary100 : cDark100,
                  ),
                ),

                /// --- Qris Wrapper Section ---
                const SizedBox(height: 24),
                isStartLoadQris ? _buildQris() : SizedBox.shrink(),

                /// --- Button Action Section ---
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton.icon(
                      onPressed: _downloadQrCode,
                      icon: const Icon(Icons.file_download),
                      label: const Text('Unduh'),
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.blueAccent,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                    ),
                    const SizedBox(width: 24),
                    ElevatedButton.icon(
                      onPressed: _onReload,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Refresh'),
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.orangeAccent,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                    ),
                  ],
                ),

                /// --- Instruction Section ---
                const SizedBox(height: 24),
                _buildInstructions(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQris() {
    return ClipRRect(
      borderRadius: BorderRadiusGeometry.circular(8),
      child: RepaintBoundary(
        key: _qrisWrapper,
        child: Stack(
          children: [
            Image.asset('assets/bg-qris.jpg'),
            Positioned.fill(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const Text(
                    "PT. TOP MORTAR INDONESIA",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 20,
                      color: cDark100,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Text(
                    "Invoice: 123456",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 18, color: cDark100),
                  ),
                  Container(
                    padding: const EdgeInsets.all(8),
                    margin: EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blueGrey.withValues(alpha: 0.1),
                          spreadRadius: 6,
                          blurRadius: 6,
                          offset: const Offset(3, 3),
                        ),
                      ],
                    ),
                    child: Image.network(
                      qrImageUrl,
                      errorBuilder: (context, error, stackTrace) => const Column(
                        children: [
                          Icon(Icons.error, size: 40, color: Colors.grey),
                          SizedBox(height: 8),
                          Text(
                            'Gagal memuat QR Code, cobalah beberapa saat lagi.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.black45,
                            ),
                          ),
                        ],
                      ),
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

  Widget _buildInstructions() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cPrimary600.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Panduan Penggunaan',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: cPrimary100,
            ),
          ),
          SizedBox(height: 12),
          Text(
            '1. Buka aplikasi pembayaran Anda (misalnya: GoPay, OVO, Dana, dll.)',
            style: TextStyle(fontSize: 14, color: cDark100),
          ),
          SizedBox(height: 8),
          Text(
            '2. Pilih menu "Scan QR" atau "Pembayaran".',
            style: TextStyle(fontSize: 14, color: cDark100),
          ),
          SizedBox(height: 8),
          Text(
            '3. Arahkan kamera ponsel Anda ke QR Code di atas.',
            style: TextStyle(fontSize: 14, color: cDark100),
          ),
          SizedBox(height: 8),
          Text(
            '4. Pastikan jumlah pembayaran sudah benar, lalu konfirmasi pembayaran.',
            style: TextStyle(fontSize: 14, color: cDark100),
          ),
        ],
      ),
    );
  }

  String _formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }
}
