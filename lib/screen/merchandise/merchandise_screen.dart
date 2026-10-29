import 'dart:async';

import 'package:flutter/material.dart';
import 'package:topmortarseller/model/merchandise_model.dart';
import 'package:topmortarseller/screen/merchandise/merchandise_detail_screen.dart';
import 'package:topmortarseller/screen/merchandise/merchandise_widgets.dart';
import 'package:topmortarseller/screen/profile/point_history_screen.dart';
import 'package:topmortarseller/services/merchandise_api.dart';
import 'package:topmortarseller/services/merchandise_points.dart';
import 'package:topmortarseller/services/notification_service.dart';
import 'package:topmortarseller/util/colors/color.dart';

class MerchandiseScreen extends StatefulWidget {
  const MerchandiseScreen({
    super.key,
    required this.idContact,
    this.onPointsChanged,
  });

  final String idContact;
  final ValueChanged<int?>? onPointsChanged;

  @override
  State<MerchandiseScreen> createState() => _MerchandiseScreenState();
}

class _MerchandiseScreenState extends State<MerchandiseScreen> {
  late final MerchandisePoints _points;
  List<MerchandiseModel> _items = [];
  bool _isLoading = true;
  bool _isOpeningItem = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _points = MerchandisePoints(
      idContact: widget.idContact,
      onChanged: widget.onPointsChanged,
    );
    _refresh();
  }

  @override
  void dispose() {
    _points.dispose();
    super.dispose();
  }

  Future<void> _refresh() async {
    await Future.wait([_loadItems(), _points.refresh()]);
  }

  Future<void> _loadItems() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    String? error;
    await MerchandiseApi().list(
      onError: (message) => error = message,
      onCompleted: (items) {
        if (!mounted) return;
        setState(() {
          _items = items ?? [];
          _error = error;
          _isLoading = false;
        });
      },
    );
  }

  Future<void> _openItem(MerchandiseModel item) async {
    if (_isOpeningItem) return;
    _isOpeningItem = true;
    final redeemed = await Navigator.of(context).push<MerchandiseModel>(
      MaterialPageRoute(
        builder: (_) =>
            MerchandiseDetailScreen(id: item.idMerchandise, points: _points),
      ),
    );
    _isOpeningItem = false;
    if (!mounted || redeemed == null) return;
    final message =
        '${redeemed.nameMerchandise} berhasil ditukar dengan '
        '${formatPoints(redeemed.pointCost!)} poin.';
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          duration: const Duration(seconds: 6),
          action: SnackBarAction(label: 'Riwayat', onPressed: _openHistory),
        ),
      );
    unawaited(_notifyRedeemed(message));
    await _refresh();
  }

  Future<void> _notifyRedeemed(String message) async {
    try {
      await NotificationService().show(
        id: DateTime.now().millisecondsSinceEpoch.remainder(2147483647),
        title: 'Penukaran poin berhasil',
        body: message,
      );
    } catch (error) {
      // The in-app success message remains available if OS permission is denied.
      debugPrint('Unable to show redemption notification: $error');
    }
  }

  Future<void> _openHistory() async {
    if (!mounted) return;
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PointHistoryScreen(idContact: widget.idContact),
      ),
    );
    if (mounted) await _points.refresh();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: cWhite,
      appBar: AppBar(
        title: const Text('Tukar Poin'),
        actions: [
          IconButton(
            onPressed: _openHistory,
            tooltip: 'Riwayat Poin',
            icon: const Icon(Icons.history_rounded),
          ),
        ],
      ),
      body: SafeArea(
        child: ListenableBuilder(
          listenable: _points,
          builder: (context, _) => RefreshIndicator.adaptive(
            onRefresh: _refresh,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              children: [
                MerchandiseBalanceCard(points: _points),
                const SizedBox(height: 24),
                Text(
                  'Pilih Merchandise',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                const Text('Lihat detail dan jumlah poin sebelum menukar.'),
                const SizedBox(height: 16),
                if (_isLoading)
                  const Padding(
                    padding: EdgeInsets.all(40),
                    child: Center(child: CircularProgressIndicator.adaptive()),
                  )
                else if (_error != null)
                  _status(
                    Icons.wifi_off_rounded,
                    'Merchandise belum dapat dimuat.',
                    retry: true,
                  )
                else if (_items.isEmpty)
                  _status(
                    Icons.card_giftcard_rounded,
                    'Belum ada merchandise. Cek kembali nanti, ya.',
                  )
                else
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final columns = constraints.maxWidth >= 600 ? 3 : 2;
                      final useSingleColumn =
                          constraints.maxWidth < 340 ||
                          MediaQuery.textScalerOf(context).scale(16) > 20;
                      final count = useSingleColumn ? 1 : columns;
                      final width =
                          (constraints.maxWidth - (count - 1) * 12) / count;
                      return Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: [
                          for (final item in _items)
                            SizedBox(width: width, child: _itemCard(item)),
                        ],
                      );
                    },
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _status(IconData icon, String message, {bool retry = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 16),
      child: Column(
        children: [
          Icon(icon, size: 48, color: cDark300),
          const SizedBox(height: 12),
          Text(message, textAlign: TextAlign.center),
          TextButton.icon(
            onPressed: _loadItems,
            icon: const Icon(Icons.refresh),
            label: Text(retry ? 'Coba Lagi' : 'Muat ulang merchandise'),
          ),
        ],
      ),
    );
  }

  Widget _itemCard(MerchandiseModel item) {
    final cost = item.pointCost;
    final total = _points.isLoading ? null : _points.total;
    final affordable = cost != null && total != null && total >= cost;
    final status = cost == null
        ? 'Belum tersedia'
        : total == null
        ? 'Lihat detail'
        : affordable
        ? 'Poin cukup'
        : 'Kurang ${formatPoints(cost - total)} poin';
    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      color: Colors.white,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: cDark500),
      ),
      child: InkWell(
        onTap: () => _openItem(item),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            MerchandiseImage(url: item.imgMerchandise),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.nameMerchandise,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    cost == null
                        ? 'Poin belum tersedia'
                        : '${formatPoints(cost)} poin',
                    style: const TextStyle(
                      color: cPrimary100,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    status,
                    style: TextStyle(
                      color: affordable ? Colors.green.shade800 : cDark200,
                      fontSize: 12,
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
