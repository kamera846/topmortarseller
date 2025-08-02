import 'package:flutter/material.dart';
import 'package:topmortarseller/model/invoice_model.dart';
import 'package:topmortarseller/services/invoice_api.dart';
import 'package:topmortarseller/util/colors/color.dart';
import 'package:topmortarseller/util/currency_format.dart';
import 'package:topmortarseller/util/date_format.dart';
import 'package:topmortarseller/util/enum.dart';
import 'package:topmortarseller/util/phone_format.dart';
import 'package:topmortarseller/widget/modal/loading_modal.dart';
import 'package:topmortarseller/widget/snackbar/show_snackbar.dart';

class InvoiceDetailScreen extends StatefulWidget {
  const InvoiceDetailScreen({super.key, required this.idInvoice});

  final String idInvoice;

  @override
  State<InvoiceDetailScreen> createState() => _InvoiceDetailScreenState();
}

class _InvoiceDetailScreenState extends State<InvoiceDetailScreen> {
  late InvoiceModel invoice;
  bool isLoading = true;
  double totalInvoice = 0.0;

  @override
  void initState() {
    super.initState();
    _onRefresh();
  }

  Future<void> _onRefresh() async {
    setState(() {
      isLoading = true;
    });
    _getList();
  }

  void _getList() async {
    await InvoiceApi().detail(
      idInvoice: widget.idInvoice,
      onError: (e) => showSnackBar(context, e),
      onCompleted: (data) {
        setState(() {
          invoice = data ?? InvoiceModel();
          totalInvoice = double.tryParse(invoice.totalInvoice) != null
              ? double.parse(invoice.totalInvoice)
              : 0.0;
          isLoading = false;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: cDark600,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Tagihan Saya'),
        centerTitle: false,
        backgroundColor: cWhite,
        foregroundColor: cDark100,
      ),
      body: SafeArea(
        child: isLoading
            ? const LoadingModal()
            : RefreshIndicator.adaptive(
                onRefresh: () => _onRefresh(),
                child: SingleChildScrollView(
                  child: Card(
                    margin: const EdgeInsets.all(12),
                    color: cWhite,
                    elevation: 0,
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Section Header
                          _sectionHeader(),
                          // Section Detail Invoice
                          _sectionDetailInvoice(),
                          // Section List Product
                          _sectionProducts(),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
      ),
    );
  }

  Column _sectionProducts() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Produk yang dibeli',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        Container(
          margin: const EdgeInsets.symmetric(vertical: 12),
          child: const Divider(height: 1, color: cDark500),
        ),
        ListView.separated(
          shrinkWrap: true,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          physics: const NeverScrollableScrollPhysics(),
          itemCount: invoice.item.length,
          padding: EdgeInsets.zero,
          itemBuilder: (ctx, idx) {
            var item = invoice.item[idx];
            double price = double.tryParse(item.price) != null
                ? double.parse(item.price)
                : 0.0;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.namaProduk,
                  style: TextStyle(fontWeight: FontWeight.w400),
                ),
                Row(
                  children: [
                    Text(
                      CurrencyFormat().format(amount: price, fractionDigits: 2),
                      style: TextStyle(
                        color: cDark200,
                        decoration: item.isBonus == '1'
                            ? TextDecoration.lineThrough
                            : TextDecoration.none,
                        decorationColor: cDark200,
                        decorationThickness: 2,
                      ),
                    ),
                    item.isBonus == '1'
                        ? Padding(
                            padding: const EdgeInsets.only(left: 8),
                            child: Text(
                              '(Free)',
                              style: TextStyle(color: cDark200),
                            ),
                          )
                        : const SizedBox.shrink(),
                    const Spacer(),
                    Text(
                      'x${item.qtyProduk}',
                      style: TextStyle(color: cDark200),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
        Container(
          margin: const EdgeInsets.symmetric(vertical: 24),
          child: const Divider(height: 1, color: cDark500),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Total', style: TextStyle(fontWeight: FontWeight.bold)),
            Text(
              CurrencyFormat().format(amount: totalInvoice),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Container _sectionDetailInvoice() {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Diterbitkan ${MyDateFormat.formatDateTime(invoice.dateInvoice)}',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Container(
            margin: const EdgeInsets.symmetric(vertical: 12),
            child: const Divider(height: 1, color: cDark500),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Ditagihkan kepada:'),
              Text(invoice.billToName),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Nomor Telpon:'),
              Text(MyPhoneFormat.format(invoice.billToPhone)),
            ],
          ),
          const SizedBox(height: 8),
          const Text('Alamat:'),
          Text(invoice.billToAddress),
        ],
      ),
    );
  }

  Container _sectionHeader() {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: cDark600,
              border: Border.all(color: cDark600, width: 1),
              borderRadius: BorderRadius.circular(70),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(70),
              child: Image.asset('assets/favicon/favicon_white.png'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Top Mortar Seller',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    _generateStatusBadge(),
                  ],
                ),
                Text('# Invoices ${invoice.noInvoie}'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Container _generateStatusBadge() {
    final status = invoice.statusInvoice.toLowerCase();
    List<Color> badgeColor = List.of({
      Colors.grey.shade400,
      Colors.grey.shade800,
    });
    if (status == StatusOrder.waiting.name) {
      badgeColor = List.of({Colors.orange.shade100, Colors.orange.shade800});
    } else if (status == StatusOrder.paid.name) {
      badgeColor = List.of({Colors.green.shade100, Colors.green.shade800});
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: badgeColor[0].withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        invoice.statusInvoice == StatusOrder.paid.name
            ? 'LUNAS'
            : 'BELUM LUNAS',
        style: TextStyle(
          color: badgeColor[1],
          fontWeight: FontWeight.bold,
          fontSize: 10,
        ),
      ),
    );
  }
}
