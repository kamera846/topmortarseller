import 'package:flutter/material.dart';
import 'package:topmortarseller/model/claimed_model.dart';
import 'package:topmortarseller/model/contact_model.dart';
import 'package:topmortarseller/model/customer_bank_model.dart';
import 'package:topmortarseller/screen/profile/new_rekening_screen.dart';
import 'package:topmortarseller/screen/profile/point_history_screen.dart';
import 'package:topmortarseller/services/claim_api.dart';
import 'package:topmortarseller/services/customer_bank_api.dart';
import 'package:topmortarseller/util/colors/color.dart';
import 'package:topmortarseller/util/date_format.dart';
import 'package:topmortarseller/util/enum.dart';
import 'package:topmortarseller/util/loading_item.dart';
import 'package:topmortarseller/util/phone_format.dart';
import 'package:topmortarseller/widget/card/card_rekening.dart';
import 'package:topmortarseller/widget/form/button/elevated_button.dart';
import 'package:topmortarseller/widget/snackbar/show_snackbar.dart';

class DetailProfileScreen extends StatefulWidget {
  const DetailProfileScreen({super.key, this.userData});

  final ContactModel? userData;

  @override
  State<DetailProfileScreen> createState() => _DetailProfileScreenState();
}

class _DetailProfileScreenState extends State<DetailProfileScreen> {
  ContactModel? _userData;
  List<CustomerBankModel> _banks = [];
  List<ClaimedModel> _redeems = [];
  int _totalQuota = 0;
  bool _isLoading = true;

  String? get _idContact => _userData?.idContact;
  bool get _hasContact => _idContact != null && _idContact!.isNotEmpty;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() => _isLoading = true);
    final data = widget.userData ?? await getContactModel();
    if (!mounted) return;
    setState(() => _userData = data);
    await _loadDetails();
  }

  void _showError(String message) {
    if (mounted && message != 'Tidak ada data') {
      showSnackBar(context, message);
    }
  }

  Future<void> _loadDetails() async {
    if (!mounted) return;
    if (!_hasContact) {
      setState(() => _isLoading = false);
      return;
    }
    setState(() => _isLoading = true);
    await Future.wait([_loadBanks(), _loadVouchers()]);
    if (!mounted) return;
    setState(() => _isLoading = false);
  }

  Future<void> _loadBanks() async {
    final banks = await CustomerBankApiService().banks(
      idContact: _idContact!,
      onSuccess: (_) {},
      onError: _showError,
      onCompleted: () {},
    );
    if (!mounted) return;
    setState(() => _banks = banks ?? []);
  }

  Future<void> _loadVouchers() async {
    var quota = 0;
    final redeems = await ClaimCashbackServices().claimed(
      idContact: _idContact!,
      onSuccess: (_) {},
      onError: _showError,
      onCompleted: (response) {
        quota = int.tryParse(response?.quota ?? '') ?? 0;
      },
    );
    if (!mounted) return;
    setState(() {
      _redeems = redeems ?? [];
      _totalQuota = quota;
    });
  }

  void _openBank({CustomerBankModel? bank}) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => NewRekeningScreen(
          userData: _userData,
          rekeningId: bank?.idRekeningToko ?? '-1',
          onSuccess: (success) {
            if (success == true && mounted) _loadDetails();
          },
        ),
      ),
    );
  }

  Widget _buildBanks() {
    final bank = _banks.firstOrNull;
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Daftar Rekening',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          Text(
            'Digunakan untuk tujuan transfer promo cashback dari kami.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 16),
          if (bank != null)
            CardRekening(
              bankName: bank.namaBank ?? '-',
              rekening: bank.toAccount ?? '-',
              rekeningName: bank.toName ?? '-',
              badge: 'default',
              rightIcon: Icons.mode_edit,
              isMaskedRekening: true,
              action: () => _openBank(bank: bank),
            )
          else
            Center(
              child: Column(
                children: [
                  const Text('Anda belum menambahkan rekening!'),
                  const SizedBox(height: 12),
                  MElevatedButton(
                    title: 'Tambah Rekening',
                    onPressed: () => _openBank(),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDetails() {
    if (!_hasContact) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Data profil tidak tersedia.'),
            TextButton(onPressed: _loadProfile, child: const Text('Coba Lagi')),
          ],
        ),
      );
    }
    final remainingQuota = _totalQuota - _redeems.length;
    final availableQuota = remainingQuota < 0 ? 0 : remainingQuota;
    return RefreshIndicator.adaptive(
      onRefresh: _loadDetails,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.zero,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Material(
              color: cPrimary100.withValues(alpha: 0.07),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: cPrimary100.withValues(alpha: 0.18)),
              ),
              clipBehavior: Clip.antiAlias,
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                leading: const CircleAvatar(
                  backgroundColor: cPrimary100,
                  child: Icon(Icons.stars_rounded, color: Colors.white),
                ),
                title: const Text(
                  'Riwayat Poin',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: cPrimary100,
                  ),
                ),
                subtitle: const Text(
                  'Lihat poin masuk dan penukaran poin Anda',
                ),
                trailing: const Icon(Icons.chevron_right, color: cPrimary100),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => PointHistoryScreen(idContact: _idContact!),
                  ),
                ),
              ),
            ),
          ),
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(24),
              child: Center(child: CircularProgressIndicator.adaptive()),
            )
          else ...[
            _buildBanks(),
            Container(
              color: cDark500,
              padding: const EdgeInsets.all(12),
              child: Text(
                'Penukaran Voucher ($availableQuota kuota tersisa)',
                style: Theme.of(
                  context,
                ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
            if (_redeems.isEmpty)
              const Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'Riwayat penukaran voucher Anda akan ditampilkan di sini.',
                  textAlign: TextAlign.center,
                ),
              ),
            for (final redeem in _redeems) ...[
              ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 8,
                ),
                title: Text(redeem.nama ?? '-'),
                subtitle: Text(
                  MyDateFormat.formatDateTime(
                    redeem.claimDate ?? '',
                    outputFormat: 'dd MMMM yyyy, HH:mm',
                  ),
                ),
              ),
              const Divider(height: 1, color: cDark500),
            ],
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(24),
            child: DetailProfileHeader(
              title: _userData?.nama ?? (_isLoading ? null : 'Profil'),
              phone: _userData?.nomorhp,
              description: _userData?.address,
            ),
          ),
          Expanded(
            child: Material(
              color: cWhite,
              child: _isLoading && !_hasContact
                  ? const Center(child: CircularProgressIndicator.adaptive())
                  : _buildDetails(),
            ),
          ),
        ],
      ),
    );
  }
}

class DetailProfileHeader extends StatelessWidget {
  const DetailProfileHeader({
    super.key,
    required this.title,
    required this.phone,
    required this.description,
  });

  final String? title;
  final String? phone;
  final String? description;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Hero(
              tag: TagHero.mainDrawerHeader,
              child: Icon(Icons.storefront, size: 24, color: cWhite),
            ),
            const SizedBox(width: 12),
            title == null
                ? const Expanded(child: LoadingItem(isPrimaryTheme: true))
                : Expanded(
                    child: Text(
                      title!,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.normal,
                        fontSize: 20,
                      ),
                    ),
                  ),
          ],
        ),
        const SizedBox(height: 6),
        phone == null
            ? const SizedBox.shrink()
            : Text(
                MyPhoneFormat.format(phone!),
                softWrap: true,
                overflow: TextOverflow.visible,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium!.copyWith(color: cWhite),
              ),
        description == null
            ? const SizedBox.shrink()
            : Text(
                description!,
                softWrap: true,
                overflow: TextOverflow.visible,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium!.copyWith(color: cWhite),
              ),
      ],
    );
  }
}
