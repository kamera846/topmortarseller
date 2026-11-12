import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:topmortarseller/model/point_model.dart';
import 'package:topmortarseller/services/point_api.dart';
import 'package:topmortarseller/util/colors/color.dart';
import 'package:topmortarseller/util/date_format.dart';

enum _PointFilter {
  all('Semua'),
  incoming('Poin Masuk'),
  outgoing('Poin Keluar');

  const _PointFilter(this.label);
  final String label;
}

class PointHistoryScreen extends StatefulWidget {
  const PointHistoryScreen({super.key, required this.idContact});

  final String idContact;

  @override
  State<PointHistoryScreen> createState() => _PointHistoryScreenState();
}

class _PointHistoryScreenState extends State<PointHistoryScreen> {
  List<PointModel> _history = [];
  _PointFilter _filter = _PointFilter.all;
  bool _isLoading = true;
  bool _isTotalLoading = true;
  int? _total;
  String? _error;
  String? _totalError;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  Future<void> _refresh() async {
    await Future.wait([_loadHistory(), _loadTotal()]);
  }

  Future<void> _loadTotal() async {
    setState(() {
      _isTotalLoading = true;
      _totalError = null;
    });
    String? error;
    final total = await PointApi.total(
      idContact: widget.idContact,
      onError: (message) => error = message,
      onCompleted: (_) {},
    );
    if (!mounted) return;
    setState(() {
      _total = error == null ? total : null;
      _totalError = error;
      _isTotalLoading = false;
    });
  }

  Future<void> _loadHistory() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    String? error;
    final history = await PointApi.history(
      idContact: widget.idContact,
      onError: (message) => error = message,
      onCompleted: (_) {},
    );
    if (!mounted) return;
    history.sort((a, b) {
      final dateComparison = (b.createdAt ?? DateTime(0)).compareTo(
        a.createdAt ?? DateTime(0),
      );
      if (dateComparison != 0) return dateComparison;
      return (int.tryParse(b.idPoint) ?? 0).compareTo(
        int.tryParse(a.idPoint) ?? 0,
      );
    });
    setState(() {
      _history = history;
      _error = error;
      _isLoading = false;
    });
  }

  Future<void> _showFilters() async {
    final selected = await showModalBottomSheet<_PointFilter>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                child: Text(
                  'Filter Riwayat Poin',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              for (final filter in _PointFilter.values)
                ListTile(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  selected: _filter == filter,
                  selectedColor: cPrimary100,
                  selectedTileColor: cPrimary100.withValues(alpha: 0.07),
                  title: Text(filter.label),
                  trailing: Icon(
                    _filter == filter
                        ? Icons.radio_button_checked
                        : Icons.radio_button_off,
                  ),
                  onTap: () => Navigator.of(context).pop(filter),
                ),
            ],
          ),
        ),
      ),
    );
    if (!mounted || selected == null) return;
    setState(() => _filter = selected);
  }

  Widget _buildTotal() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [cPrimary100, cPrimary200],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.stars_rounded, color: Colors.white, size: 24),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Total Poin',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_isTotalLoading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: LinearProgressIndicator(
                color: Colors.white,
                backgroundColor: cPrimary300,
              ),
            )
          else if (_totalError != null) ...[
            const Text(
              'Total poin belum dapat dimuat.',
              style: TextStyle(color: Colors.white),
            ),
            TextButton.icon(
              style: TextButton.styleFrom(foregroundColor: Colors.white),
              onPressed: _loadTotal,
              icon: const Icon(Icons.refresh),
              label: const Text('Muat ulang total'),
            ),
          ] else
            Text(
              '${NumberFormat.decimalPattern('id_ID').format(_total ?? 0)} poin',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildHistory() {
    final items = _history.where((point) {
      return switch (_filter) {
        _PointFilter.all => true,
        _PointFilter.incoming => !point.isRedeemed,
        _PointFilter.outgoing => point.isRedeemed,
      };
    }).toList();
    final showStatus = _isLoading || _error != null || items.isEmpty;
    return RefreshIndicator.adaptive(
      onRefresh: _refresh,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(bottom: 16),
        itemCount: 2 + (showStatus ? 1 : items.length),
        itemBuilder: (context, index) {
          if (index == 0) return _buildTotal();
          if (index == 1) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: Text(
                'Transaksi • ${_filter.label}',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
            );
          }
          if (_isLoading) {
            return const Padding(
              padding: EdgeInsets.all(32),
              child: Center(child: CircularProgressIndicator.adaptive()),
            );
          }
          if (_error != null) {
            return Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const Icon(Icons.error_outline, color: cPrimary100, size: 40),
                  const SizedBox(height: 12),
                  const Text('Gagal memuat riwayat poin.'),
                  const SizedBox(height: 8),
                  Text(_error!, textAlign: TextAlign.center),
                  TextButton(
                    onPressed: _loadHistory,
                    child: const Text('Coba Lagi'),
                  ),
                ],
              ),
            );
          }
          if (items.isEmpty) {
            return Padding(
              padding: const EdgeInsets.all(32),
              child: Text(switch (_filter) {
                _PointFilter.all => 'Belum ada riwayat poin.',
                _PointFilter.incoming => 'Belum ada poin masuk.',
                _PointFilter.outgoing => 'Belum ada penukaran poin.',
              }, textAlign: TextAlign.center),
            );
          }
          return Column(
            children: [
              _PointHistoryItem(point: items[index - 2]),
              if (index < items.length + 1)
                const Divider(height: 1, indent: 16, endIndent: 16),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: cWhite,
      appBar: AppBar(title: const Text('Riwayat Poin')),
      body: SafeArea(bottom: false, child: _buildHistory()),
      // Reserve layout space for the floating control so it never covers a row.
      bottomNavigationBar: SafeArea(
        top: false,
        minimum: const EdgeInsets.fromLTRB(16, 8, 16, 12),
        child: Align(
          heightFactor: 1,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Material(
              color: Colors.white,
              elevation: 6,
              shadowColor: Colors.black26,
              borderRadius: BorderRadius.circular(28),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: _showFilters,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.tune_rounded, color: cPrimary100),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Filter: ${_filter.label}',
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                      const Icon(
                        Icons.keyboard_arrow_up_rounded,
                        color: cPrimary100,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PointHistoryItem extends StatelessWidget {
  const _PointHistoryItem({required this.point});

  final PointModel point;

  @override
  Widget build(BuildContext context) {
    final color = point.isRedeemed ? cPrimary100 : Colors.green.shade700;
    final status = point.isRedeemed ? 'Poin digunakan' : 'Poin diterima';
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: Icon(
        point.isRedeemed ? Icons.arrow_upward : Icons.arrow_downward,
        color: color,
      ),
      title: Text(point.sourcePoint.isEmpty ? status : point.sourcePoint),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(status, style: TextStyle(color: color)),
          Text(
            MyDateFormat.formatDateTime(
              point.createdAt?.toIso8601String() ?? '',
              outputFormat: 'dd MMMM yyyy, HH:mm',
            ),
          ),
          if (point.isRedeemed)
            Text('Penukaran #${point.idPointRedeem}')
          else if (point.idInvoice.isNotEmpty)
            Text('Invoice #${point.idInvoice}'),
        ],
      ),
      trailing: Text(
        '${point.formattedValue} poin',
        style: TextStyle(color: color, fontWeight: FontWeight.bold),
      ),
    );
  }
}
