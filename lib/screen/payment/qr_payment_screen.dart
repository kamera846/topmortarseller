import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';
import 'package:topmortarseller/model/qris_model.dart';
import 'package:topmortarseller/services/qris_api.dart';
import 'package:topmortarseller/util/colors/color.dart';
import 'package:topmortarseller/util/enum.dart';
import 'package:topmortarseller/widget/modal/modal_action.dart';

class QrPaymentScreen extends StatefulWidget {
  final String idQrisPayment;
  final bool isWillGetPoint;
  const QrPaymentScreen({
    super.key,
    required this.idQrisPayment,
    this.isWillGetPoint = false,
  });

  @override
  State<QrPaymentScreen> createState() => _QrPaymentScreenState();
}

class _QrPaymentScreenState extends State<QrPaymentScreen>
    with WidgetsBindingObserver {
  final GlobalKey _qrisWrapper = GlobalKey();

  final int _expiryDurationInSecond = 1800;
  int _remainingSeconds = 0;
  Timer? _timer;
  Timer? _timerRefresh;

  QrisModel? qrisData;
  bool _canPop = false;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _getQrisPayment();
  }

  @override
  void dispose() {
    _resetTimer();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      await Future.delayed(Duration(milliseconds: 250));
      if (!mounted) return;
      _onReload();
    } else {
      _resetTimer();
    }
  }

  void _onReload() {
    _resetTimer();
    _getQrisPayment();
  }

  void _resetTimer() {
    _timer?.cancel();
    _timerRefresh?.cancel();
  }

  void _getQrisPayment() async {
    setState(() {
      isLoading = true;
    });
    await QrisApi().payment(
      idQrisPayment: widget.idQrisPayment,
      onError: (e) => _showErrordDialog(e),
      onCompleted: (data) {
        _resetTimer();
        if (data != null) {
          if (data.statusQrisPayment == 'unpaid') {
            setState(() {
              qrisData = data;
            });
            _startTimer();
          } else if (data.statusQrisPayment == 'paid') {
            _showIsPaidDialog();
          }
        }
        setState(() {
          isLoading = false;
        });
      },
    );
  }

  void _startTimer() {
    if (qrisData == null) return;

    String initialTimeString = qrisData!.dateQrisPayment;
    DateTime initialTime = DateTime.parse(initialTimeString);
    DateTime endTime = initialTime.add(
      Duration(seconds: _expiryDurationInSecond),
    );
    DateTime currentTime = DateTime.now();
    Duration difference = endTime.difference(currentTime);

    // Countdown Interval
    _remainingSeconds = difference.inSeconds;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() {
          _remainingSeconds--;
        });
      } else {
        _resetTimer();
        Future.delayed(Duration(seconds: 1), () {
          _onReload();
        });
      }
    });
    // Auto Refresh Interval
    _timerRefresh = Timer.periodic(const Duration(seconds: 30), (timer) {
      _getQrisPayment();
    });
  }

  void _showIsPaidDialog() {
    showAdaptiveDialog(
      context: context,
      builder: (context) => AlertDialog.adaptive(
        title: const Text('Pembayaran Berhasil!'),
        content: const Text(
          'Terimakasih, pembayaran anda telah berhasil diselesaikan.',
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
      _onPopPaid();
    });
  }

  void _showErrordDialog(String error) {
    showAdaptiveDialog(
      context: context,
      builder: (context) => AlertDialog.adaptive(
        title: const Text('Terjadi Kesalahan!'),
        content: Text(error),
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
      _onPopRefresh();
    });
  }

  void _onPopRefresh() {
    final Map<String, dynamic> popValue = {
      'popValue': PopValue.needRefresh,
      'willGetPoint': widget.isWillGetPoint,
    };
    Navigator.of(context).pop(popValue);
  }

  void _onPopPaid() {
    final Map<String, dynamic> popValue = {
      'popValue': PopValue.isPaid,
      'willGetPoint': widget.isWillGetPoint,
    };
    Navigator.of(context).pop(popValue);
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
      final filename =
          "QRISMYTOPSELLER${qrisData?.invQrisPayment}${DateTime.now().millisecondsSinceEpoch}";
      final tempFilePath = '${tempDir.path}/$filename.jpg';
      final tempFile = File(tempFilePath);
      await tempFile.writeAsBytes(pngBytes);

      if (!mounted) return;

      // Save image on android
      if (Platform.isAndroid) {
        final result = await ImageGallerySaverPlus.saveImage(
          pngBytes,
          name: filename,
          quality: 100,
        );

        if (!mounted) return;
        if (result['isSuccess'] == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('QRIS berhasil disimpan ke Galeri!')),
          );
        } else if (result['errorMessage'] != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Gagal menyimpan ke Galeri: Error ${result['errorMessage']}',
              ),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Gagal menyimpan ke Galeri: $result')),
          );
        }
        // Share image to save on IOS
      } else if (Platform.isIOS) {
        final result = await SharePlus.instance.share(
          ShareParams(
            files: [XFile(tempFile.path, name: "$filename.jpg")],
            title: "$filename.jpg",
            sharePositionOrigin:
                renderObject.localToGlobal(Offset.zero) & renderObject.size,
          ),
        );

        if (!mounted) return;
        if (result.status == ShareResultStatus.success) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(result.raw)));
        } else if (result.status != ShareResultStatus.dismissed) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(result.toString())));
        }
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Gagal menyimpan!")));
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
    } else {
      return true;
    }
  }

  @override
  Widget build(BuildContext context) {
    String formattedTime = _formatTime(_remainingSeconds);
    return PopScope(
      canPop: _canPop && !isLoading,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop || isLoading) return;
        setState(() {
          _canPop = true;
        });
        _onPopRefresh();
      },
      child: Scaffold(
        backgroundColor: cDark600,
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: isLoading ? null : () => _onPopRefresh(),
          ),
          title: const Text('Pembayaran QRIS'),
          centerTitle: false,
          backgroundColor: cWhite,
          foregroundColor: cDark100,
          scrolledUnderElevation: 0,
          shape: Border(bottom: BorderSide(color: cDark500)),
          bottom: PreferredSize(
            preferredSize: Size(double.infinity, 4),
            child: isLoading
                ? LinearProgressIndicator(minHeight: 4)
                : SizedBox.shrink(),
          ),
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
                    'Scan QRIS di bawah ini untuk menyelesaikan pembayaran sebelum kode kadaluarsa dalam:',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, color: cDark100),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    formattedTime,
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: _remainingSeconds < 300 ? cPrimary100 : cDark100,
                    ),
                  ),

                  /// --- Qris Wrapper Section ---
                  const SizedBox(height: 24),
                  _buildQris(),

                  /// --- Button Action Section ---
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (Platform.isAndroid || Platform.isIOS)
                        ElevatedButton.icon(
                          onPressed: _downloadQrCode,
                          icon: const Icon(Icons.file_download),
                          label: Text(Platform.isAndroid ? 'Unduh' : 'Save'),
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
      ),
    );
  }

  Widget _buildQris() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
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
                  Text(
                    "INVOICE QRIS: ${qrisData?.invQrisPayment ?? '-'}",
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
                      "${qrisData?.imgQrisPayment}",
                      errorBuilder: (context, error, stackTrace) => Padding(
                        padding: const EdgeInsets.all(8),
                        child: const Column(
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
