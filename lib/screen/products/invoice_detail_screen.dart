import 'package:flutter/material.dart';
import 'package:topmortarseller/model/invoice_model.dart';
import 'package:topmortarseller/model/product_discount_modal.dart';
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
  List<ProductDiscountModel> discounts = [];
  double subTotalInvoice = 0.0;
  double discountAppInvoice = 0.0;
  double totalInvoice = 0.0;
  bool isLoading = true;

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
          discounts.clear();
          invoice = data ?? InvoiceModel();
          subTotalInvoice = double.tryParse(invoice.subTotalInvoice) != null
              ? double.parse(invoice.subTotalInvoice)
              : 0.0;
          totalInvoice = double.tryParse(invoice.totalInvoice) != null
              ? double.parse(invoice.totalInvoice)
              : 0.0;

          discountAppInvoice =
              double.tryParse(invoice.discountAppInvoice) == null
              ? 0.0
              : double.parse(invoice.discountAppInvoice);
          if (discountAppInvoice > 0.0) {
            discounts.add(
              ProductDiscountModel(
                title: 'Diskon Aplikasi',
                discount: discountAppInvoice,
              ),
            );
          }
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
        scrolledUnderElevation: 0,
        shape: Border(bottom: BorderSide(color: cDark500)),
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
            String formatPrice = CurrencyFormat().format(
              amount: price,
              fractionDigits: 2,
            );
            double amount = double.tryParse(item.amount) != null
                ? double.parse(item.amount)
                : 0.0;
            String formatAmount = CurrencyFormat().format(
              amount: amount,
              fractionDigits: 2,
            );
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.namaProduk,
                  style: TextStyle(
                    color: cDark200,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Row(
                  children: [
                    Text(
                      formatPrice,
                      style: TextStyle(
                        color: cDark200,
                        decoration: item.isBonus == '1'
                            ? TextDecoration.lineThrough
                            : TextDecoration.none,
                      ),
                    ),
                    Text(
                      ' x${item.qtyProduk}',
                      style: TextStyle(color: cDark200),
                    ),
                    const Spacer(),
                    Text(formatAmount, style: TextStyle(color: cPrimary200)),
                  ],
                ),

                item.isBonus == '1'
                    ? Text('(Free)', style: TextStyle(color: cDark200))
                    : const SizedBox.shrink(),
              ],
            );
          },
        ),
        Container(
          margin: const EdgeInsets.symmetric(vertical: 24),
          child: const Divider(height: 1, color: cDark500),
        ),
        Row(
          children: [
            const Expanded(
              child: Text(
                'Total Harga',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            Text(
              CurrencyFormat().format(
                amount: subTotalInvoice,
                fractionDigits: 2,
              ),
              style: const TextStyle(color: cPrimary200),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ListView.separated(
          itemCount: discounts.length,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (ctx, idx) {
            var discountCo = discounts[idx];
            return Row(
              children: [
                Expanded(child: Text(discountCo.title)),
                Text(
                  '- ${CurrencyFormat().format(amount: discountCo.discount, fractionDigits: 2)}',
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
          children: [
            const Expanded(
              child: Text(
                'Total Bayar',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (subTotalInvoice != totalInvoice)
                  Text(
                    CurrencyFormat().format(
                      amount: subTotalInvoice,
                      fractionDigits: 2,
                    ),
                    style: const TextStyle(
                      decoration: TextDecoration.lineThrough,
                      decorationThickness: 2,
                      color: cPrimary200,
                      decorationColor: cPrimary200,
                    ),
                  ),
                Text(
                  CurrencyFormat().format(amount: totalInvoice),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: cPrimary200,
                  ),
                ),
              ],
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
            children: [
              Text(
                'Ditagihkan Kepada:',
                style: TextStyle(color: cDark200, fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  invoice.billToName,
                  textAlign: TextAlign.end,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                'Nomor Telpon:',
                style: TextStyle(color: cDark200, fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  MyPhoneFormat.format(invoice.billToPhone),
                  maxLines: 1,
                  textAlign: TextAlign.end,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Alamat:',
            style: TextStyle(color: cDark200, fontWeight: FontWeight.bold),
          ),
          Text(
            invoice.billToAddress,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
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
