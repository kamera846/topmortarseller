import 'package:flutter/material.dart';
import 'package:topmortarseller/model/contact_model.dart';
import 'package:topmortarseller/model/invoice_model.dart';
import 'package:topmortarseller/util/colors/color.dart';
import 'package:topmortarseller/util/currency_format.dart';
import 'package:topmortarseller/util/date_format.dart';
import 'package:topmortarseller/util/enum.dart';
import 'package:topmortarseller/widget/modal/loading_modal.dart';

class InvoiceDetailScreen extends StatefulWidget {
  const InvoiceDetailScreen({super.key, required this.invoice, this.userData});

  final InvoiceModel invoice;
  final ContactModel? userData;

  @override
  State<InvoiceDetailScreen> createState() => _InvoiceDetailScreenState();
}

class _InvoiceDetailScreenState extends State<InvoiceDetailScreen> {
  bool _isLoading = true;
  ContactModel? _userData;

  @override
  void initState() {
    _getUserData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // final orderStatus = widget.invoice.statusInvoice.toLowerCase();
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
      // bottomNavigationBar: orderStatus == StatusOrder.waiting.name
      //     ? _sectionButtonPayment()
      //     : null,
      body: SafeArea(
        child: _isLoading
            ? const LoadingModal()
            : SingleChildScrollView(
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
    );
  }

  // Container _sectionButtonPayment() {
  //   return Container(
  //     width: double.infinity,
  //     padding: const EdgeInsets.all(24),
  //     decoration: const BoxDecoration(
  //       color: Colors.white,
  //       border: Border.symmetric(
  //         horizontal: BorderSide(color: cDark600, width: 1),
  //       ),
  //     ),
  //     child: SafeArea(
  //       child: MElevatedButton(
  //         onPressed: () {},
  //         title: 'Bayar Sekarang',
  //         isFullWidth: true,
  //       ),
  //     ),
  //   );
  // }

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
          separatorBuilder: (context, index) => const SizedBox(height: 8),
          physics: const NeverScrollableScrollPhysics(),
          itemCount: widget.invoice.item.length,
          padding: EdgeInsets.zero,
          itemBuilder: (ctx, idx) {
            var item = widget.invoice.item[idx];
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
                      CurrencyFormat().format(
                        amount: double.parse(item.price),
                        fractionDigits: 2,
                      ),
                      style: TextStyle(
                        color: cDark200,
                        decoration: item.isBonus == '1'
                            ? TextDecoration.lineThrough
                            : TextDecoration.none,
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
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Total', style: TextStyle(fontWeight: FontWeight.bold)),
            Text(
              CurrencyFormat().format(
                amount: double.parse(widget.invoice.totalInvoice),
                fractionDigits: 2,
              ),
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
            'Diterbitkan ${MyDateFormat.formatDateTime(widget.invoice.dateInvoice)}',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Container(
            margin: const EdgeInsets.symmetric(vertical: 12),
            child: const Divider(height: 1, color: cDark500),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Ditagihkan kepada'),
              Text(_userData?.nama ?? '-'),
            ],
          ),
          const SizedBox(height: 6),
          // Row(
          //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //   children: [
          //     const Text('Total bayar'),
          //     Text(
          //       CurrencyFormat().format(
          //         amount: double.parse(widget.invoice.totalInvoice),
          //         fractionDigits: 2,
          //       ),
          //     ),
          //   ],
          // ),
          const SizedBox(height: 6),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [Text('Tanggal bayar'), Text('-')],
          ),
        ],
      ),
    );
  }

  Container _sectionHeader() {
    final orderStatus = widget.invoice.statusInvoice.toLowerCase();
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
                    Badge(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      label: Text(
                        orderStatus == StatusOrder.paid.name
                            ? 'Lunas'
                            : 'Belum Lunas',
                      ),
                      backgroundColor: orderStatus == StatusOrder.paid.name
                          ? Colors.green[700]!
                          : Colors.orange[700]!,
                      textColor: cWhite,
                      textStyle: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Text('# Invoices ${widget.invoice.noInvoie}'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _getList() async {
    await Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        _isLoading = false;
      });
    });
  }

  void _getUserData() async {
    // final data = widget.userData ?? await getContactModel();
    final data = await getContactModel();
    setState(() {
      _userData = data;
    });
    _getList();
  }
}
