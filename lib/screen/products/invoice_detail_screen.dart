import 'package:flutter/material.dart';
import 'package:topmortarseller/model/contact_model.dart';
import 'package:topmortarseller/model/invoice_model.dart';
import 'package:topmortarseller/util/colors/color.dart';
import 'package:topmortarseller/util/currency_format.dart';
import 'package:topmortarseller/util/date_format.dart';
import 'package:topmortarseller/util/enum.dart';
import 'package:topmortarseller/util/phone_format.dart';

class InvoiceDetailScreen extends StatelessWidget {
  const InvoiceDetailScreen({super.key, required this.invoice, this.userData});

  final InvoiceModel invoice;
  final ContactModel? userData;

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
        Container(
          margin: const EdgeInsets.symmetric(vertical: 24),
          child: const Divider(height: 1, color: cDark500),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Total', style: TextStyle(fontWeight: FontWeight.bold)),
            Text(
              CurrencyFormat().format(
                amount: double.parse(invoice.totalInvoice),
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
    final orderStatus = invoice.statusInvoice.toLowerCase();
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
                Text('# Invoices ${invoice.noInvoie}'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
