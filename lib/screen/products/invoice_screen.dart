import 'package:flutter/material.dart';
import 'package:topmortarseller/model/contact_model.dart';
import 'package:topmortarseller/model/order_model.dart';
import 'package:topmortarseller/model/product_model.dart';
import 'package:topmortarseller/util/colors/color.dart';
import 'package:topmortarseller/util/currency_format.dart';
import 'package:topmortarseller/util/enum.dart';
import 'package:topmortarseller/widget/form/button/elevated_button.dart';
import 'package:topmortarseller/widget/modal/loading_modal.dart';

class InvoiceScreen extends StatefulWidget {
  const InvoiceScreen({super.key, required this.orderItem, this.userData});

  final OrderModel orderItem;
  final ContactModel? userData;

  @override
  State<InvoiceScreen> createState() => _InvoiceScreenState();
}

class _InvoiceScreenState extends State<InvoiceScreen> {
  bool _isLoading = true;
  ContactModel? _userData;

  @override
  void initState() {
    _getUserData();
    super.initState();
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
        child: _isLoading
            ? const LoadingModal()
            : Column(
                children: [
                  Card(
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
                  const Expanded(child: SizedBox(height: 12)),
                  // Section Button Payment
                  if (widget.orderItem.orderStatus == StatusOrder.invoice.name)
                    _sectionButtonPayment(),
                ],
              ),
      ),
    );
  }

  Container _sectionButtonPayment() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border.symmetric(
          horizontal: BorderSide(color: cDark600, width: 1),
        ),
      ),
      child: MElevatedButton(
        onPressed: () {},
        title: 'Bayar Sekarang',
        isFullWidth: true,
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
          separatorBuilder: (context, index) => const SizedBox(height: 6),
          physics: const NeverScrollableScrollPhysics(),
          itemCount: widget.orderItem.orderItems.length,
          padding: const EdgeInsets.all(0),
          itemBuilder: (ctx, idx) {
            var item = widget.orderItem.orderItems[idx];
            var totalPrice =
                double.parse(item.qtyCartDetail ?? '0.0') *
                double.parse(item.hargaProduk ?? '0.0');
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.namaProduk ?? '-'),
                    Text(
                      'x${item.qtyCartDetail ?? '-'}',
                      style: const TextStyle(color: cDark200),
                    ),
                  ],
                ),
                Text(
                  CurrencyFormat().format(
                    amount: totalPrice,
                    fractionDigits: 2,
                  ),
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
              _countSubTotalItems(widget.orderItem.orderItems),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
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
            'Diterbitkan pada ${widget.orderItem.orderDate}',
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Total bayar'),
              Text(_countSubTotalItems(widget.orderItem.orderItems)),
            ],
          ),
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
                        widget.orderItem.orderStatus == StatusOrder.selesai.name
                            ? 'Lunas'
                            : 'Belum Lunas',
                      ),
                      backgroundColor:
                          widget.orderItem.orderStatus ==
                              StatusOrder.selesai.name
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
                const Text('Invoices #70'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _countSubTotalItems(List<ProductModel> items) {
    var subTotalPrices = 0.0;
    for (var product in items) {
      subTotalPrices +=
          double.parse(product.qtyCartDetail ?? '0.0') *
          double.parse(product.hargaProduk ?? '0.0');
    }
    return CurrencyFormat().format(amount: subTotalPrices, fractionDigits: 2);
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
