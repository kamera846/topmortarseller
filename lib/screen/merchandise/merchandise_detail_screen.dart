import 'package:flutter/material.dart';
import 'package:topmortarseller/model/merchandise_model.dart';
import 'package:topmortarseller/screen/merchandise/merchandise_widgets.dart';
import 'package:topmortarseller/screen/profile/point_history_screen.dart';
import 'package:topmortarseller/services/merchandise_api.dart';
import 'package:topmortarseller/services/merchandise_points.dart';
import 'package:topmortarseller/services/point_api.dart';
import 'package:topmortarseller/util/colors/color.dart';

class MerchandiseDetailScreen extends StatefulWidget {
  const MerchandiseDetailScreen({
    super.key,
    required this.id,
    required this.points,
  });

  final String id;
  final MerchandisePoints points;

  @override
  State<MerchandiseDetailScreen> createState() =>
      _MerchandiseDetailScreenState();
}

class _MerchandiseDetailScreenState extends State<MerchandiseDetailScreen> {
  MerchandiseModel? _item;
  bool _isLoading = true;
  bool _isConfirming = false;
  bool _isRedeeming = false;
  String? _redeemError;

  @override
  void initState() {
    super.initState();
    // Refresh the shared balance after the new route has finished building.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _refresh();
    });
  }

  Future<void> _refresh() async {
    if (_isRedeeming || _isConfirming) return;
    await Future.wait([_loadItem(), widget.points.refresh()]);
  }

  Future<void> _loadItem() async {
    setState(() => _isLoading = true);
    await MerchandiseApi().detail(
      id: widget.id,
      onCompleted: (item) {
        if (!mounted) return;
        setState(() {
          _item = item;
          _isLoading = false;
        });
      },
    );
  }

  bool get _canRedeem {
    final cost = _item?.pointCost;
    final points = widget.points;
    return !_isLoading &&
        !_isConfirming &&
        !_isRedeeming &&
        !points.isLoading &&
        points.total != null &&
        cost != null &&
        points.total! >= cost &&
        points.idContact.isNotEmpty &&
        _item!.idMerchandise.isNotEmpty;
  }

  Future<void> _redeem() async {
    if (!_canRedeem) return;
    final item = _item!;
    final cost = item.pointCost!;
    final total = widget.points.total!;
    setState(() {
      _isConfirming = true;
      _redeemError = null;
    });
    bool answered = false;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi Penukaran'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Tukar poin untuk ${item.nameMerchandise}?'),
              const SizedBox(height: 20),
              Text('Poin saat ini: ${formatPoints(total)} poin'),
              const SizedBox(height: 8),
              Text('Poin digunakan: ${formatPoints(cost)} poin'),
              const Divider(height: 24),
              Text(
                'Sisa poin: ${formatPoints(total - cost)} poin',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              const Text('Poin akan dipotong setelah penukaran berhasil.'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              if (answered) return;
              answered = true;
              Navigator.pop(context, false);
            },
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () {
              if (answered) return;
              answered = true;
              Navigator.pop(context, true);
            },
            child: const Text('Ya, Tukar Poin'),
          ),
        ],
      ),
    );
    if (!mounted) return;
    setState(() => _isConfirming = false);
    if (confirmed != true || !_canRedeem) return;
    setState(() => _isRedeeming = true);

    String? error;
    final response = await PointApi.redeem(
      idContact: widget.points.idContact,
      idMerchandise: item.idMerchandise,
      priceMerchandise: item.priceMerchandise,
      onError: (message) => error = message,
      onCompleted: (_) {},
    );
    if (!mounted) return;
    if (response?.code == 200) {
      await widget.points.invalidate();
      if (!mounted) return;
      setState(() => _isRedeeming = false);
      Navigator.of(context).pop(item);
      return;
    }
    setState(() {
      _isRedeeming = false;
      _redeemError = error?.isNotEmpty == true
          ? error
          : 'Penukaran belum berhasil. Silakan coba kembali.';
    });
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          content: Text(_redeemError!),
          action: SnackBarAction(
            label: 'Riwayat',
            onPressed: () async {
              if (!mounted) return;
              await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) =>
                      PointHistoryScreen(idContact: widget.points.idContact),
                ),
              );
              if (mounted) await widget.points.refresh();
            },
          ),
        ),
      );
    // A rejected request may mean another transaction changed the balance.
    await widget.points.refresh();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.points,
      builder: (context, _) {
        final cost = _item?.pointCost;
        final total = widget.points.total;
        final shortfall = cost != null && total != null ? cost - total : 0;
        return PopScope(
          canPop: !_isRedeeming,
          onPopInvokedWithResult: (didPop, _) {
            if (didPop && _redeemError != null) {
              ScaffoldMessenger.of(context).clearSnackBars();
            }
          },
          child: Scaffold(
            backgroundColor: cWhite,
            appBar: AppBar(
              title: const Text('Detail Merchandise'),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                tooltip: 'Kembali',
                onPressed: _isRedeeming
                    ? null
                    : () => Navigator.of(context).pop(),
              ),
              automaticallyImplyLeading: !_isRedeeming,
            ),
            body: SafeArea(
              child: RefreshIndicator.adaptive(
                onRefresh: _refresh,
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(16),
                  children: [
                    if (_isLoading)
                      const Padding(
                        padding: EdgeInsets.all(48),
                        child: Center(
                          child: CircularProgressIndicator.adaptive(),
                        ),
                      )
                    else if (_item == null) ...[
                      const Padding(
                        padding: EdgeInsets.all(32),
                        child: Text(
                          'Detail merchandise belum dapat dimuat.',
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Center(
                        child: TextButton.icon(
                          onPressed: _refresh,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Coba Lagi'),
                        ),
                      ),
                    ] else ...[
                      ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: MerchandiseImage(url: _item!.imgMerchandise),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        _item!.nameMerchandise,
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        cost == null
                            ? 'Poin belum tersedia'
                            : '${formatPoints(cost)} poin',
                        style: const TextStyle(
                          color: cPrimary100,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 24),
                      MerchandiseBalanceCard(
                        points: widget.points,
                        enabled: !_isRedeeming,
                      ),
                      const SizedBox(height: 12),
                      if (!widget.points.isLoading &&
                          total != null &&
                          cost != null)
                        Text(
                          shortfall > 0
                              ? 'Kumpulkan ${formatPoints(shortfall)} poin lagi untuk menukar merchandise ini.'
                              : 'Sisa poin setelah penukaran: ${formatPoints(total - cost)} poin.',
                          style: TextStyle(
                            color: shortfall > 0 ? cPrimary100 : cDark200,
                          ),
                        ),
                      const SizedBox(height: 24),
                      const Text(
                        'Tentang Merchandise',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _item!.descMerchandise.isEmpty
                            ? 'Belum ada deskripsi merchandise.'
                            : _item!.descMerchandise,
                      ),
                      if (_redeemError != null) ...[
                        const SizedBox(height: 20),
                        Semantics(
                          liveRegion: true,
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: cPrimary100.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              _redeemError!,
                              style: const TextStyle(color: cPrimary100),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ],
                ),
              ),
            ),
            bottomNavigationBar: _item == null || _isLoading
                ? null
                : Container(
                    color: Colors.white,
                    child: SafeArea(
                      top: false,
                      minimum: const EdgeInsets.all(16),
                      child: FilledButton(
                        onPressed: _canRedeem ? _redeem : null,
                        style: FilledButton.styleFrom(
                          backgroundColor: cPrimary100,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 16,
                          ),
                        ),
                        child: _isRedeeming
                            ? const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  ),
                                  SizedBox(width: 12),
                                  Flexible(child: Text('Memproses penukaran…')),
                                ],
                              )
                            : Text(
                                widget.points.isLoading
                                    ? 'Memperbarui poin…'
                                    : total == null
                                    ? 'Muat saldo poin terlebih dahulu'
                                    : cost == null
                                    ? 'Belum dapat ditukar'
                                    : shortfall > 0
                                    ? 'Poin Belum Cukup'
                                    : 'Tukar ${formatPoints(cost)} Poin',
                                textAlign: TextAlign.center,
                              ),
                      ),
                    ),
                  ),
          ),
        );
      },
    );
  }
}
