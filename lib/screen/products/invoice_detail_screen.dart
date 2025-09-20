import 'package:flutter/material.dart';
import 'package:topmortarseller/model/discount_extra_model.dart';
import 'package:topmortarseller/model/invoice_model.dart';
import 'package:topmortarseller/model/product_discount_modal.dart';
import 'package:topmortarseller/model/qris_model.dart';
import 'package:topmortarseller/screen/payment/invoice_payment_screen.dart';
import 'package:topmortarseller/screen/payment/qr_payment_screen.dart';
import 'package:topmortarseller/services/invoice_api.dart';
import 'package:topmortarseller/services/notification_service.dart';
import 'package:topmortarseller/services/qris_api.dart';
import 'package:topmortarseller/util/colors/color.dart';
import 'package:topmortarseller/util/currency_format.dart';
import 'package:topmortarseller/util/date_format.dart';
import 'package:topmortarseller/util/enum.dart';
import 'package:topmortarseller/util/phone_format.dart';
import 'package:topmortarseller/widget/form/button/elevated_button.dart';
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
  PopValue popValue = PopValue.nothing;
  double subTotalInvoice = 0.0;
  double discountAppInvoice = 0.0;
  double totalInvoice = 0.0;
  double remainingInvoice = 0.0;
  double totalPayment = 0.0;
  double amountQrisPayment = 0.0;
  DiscountExtra? discountExtra;
  double amountDiscountExtra = 0.0;
  late QrisModel qrisData;

  bool isLoading = true;
  bool isAvailablePayment = false;

  int _checkPaymentAttempt = 1;

  @override
  void initState() {
    super.initState();
    _getDetail();
  }

  Future<void> _onRefresh() async {
    setState(() {
      isLoading = true;
      isAvailablePayment = false;
      _checkPaymentAttempt = 1;
    });
    _getDetail();
  }

  void _getDetail() async {
    await InvoiceApi().detail(
      idInvoice: widget.idInvoice,
      onError: (e) => showSnackBar(context, e),
      onCompleted: (data) {
        if (data != null) {
          _checkQris(data);
        } else {
          setState(() {
            discounts.clear();
            invoice = InvoiceModel();
            subTotalInvoice = 0.0;
            totalInvoice = 0.0;
            remainingInvoice = 0.0;
            totalPayment = 0.0;
            discountAppInvoice = 0.0;
            isLoading = false;
          });
        }
      },
    );
  }

  void _checkQris(InvoiceModel dataInvoice) async {
    await QrisApi().check(
      idInvoice: dataInvoice.idInvoice,
      onCompleted: (checkQrisData) {
        _checkQrisPayment(dataInvoice, checkQrisData);
      },
    );
  }

  void _checkQrisPayment(
    InvoiceModel dataInvoice,
    QrisModel? checkQrisData,
  ) async {
    /// Jika tidak ada pembayaran yang belum lunas
    /// -> Langsung setup data
    if (checkQrisData == null) {
      _setDataDetail(dataInvoice, checkQrisData);
      return;
    }

    /// Jika ada pembayaran yang belum lunas
    /// -> Cek dulu apakah masih ada kesempatan untuk cek status pembayaran
    if (_checkPaymentAttempt > 0) {
      /// -> Jika masih ada kesempatan
      /// -> Cek status pembayarannya terlebih dahulu
      /// -> Setelah itu, ulangi ke proses cek pembayaran yang belum lunas
      await QrisApi().payment(
        idQrisPayment: checkQrisData.idQrisPayment,
        onCompleted: (_) {
          _checkQris(dataInvoice);

          /// -> Kurangi kesempatan yang sudah terpakai
          setState(() {
            _checkPaymentAttempt--;
          });
        },
      );
    } else {
      _setDataDetail(dataInvoice, checkQrisData);
    }
  }

  void _setDataDetail(InvoiceModel dataInvoice, QrisModel? checkQrisData) {
    setState(() {
      discounts.clear();
      invoice = dataInvoice;
      subTotalInvoice = double.tryParse(invoice.subTotalInvoice) != null
          ? double.parse(invoice.subTotalInvoice)
          : 0.0;
      totalInvoice = double.tryParse(invoice.totalInvoice) != null
          ? double.parse(invoice.totalInvoice)
          : 0.0;
      remainingInvoice = double.tryParse(invoice.sisaInvoice) != null
          ? double.parse(invoice.sisaInvoice)
          : 0.0;

      // Set Discount App
      discountAppInvoice = double.tryParse(invoice.discountAppInvoice) == null
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

      // Set Discount Extra
      discountExtra = invoice.discountExtra;

      // If invoice paid, get value discount extra from invoice model ..
      if (invoice.statusInvoice.toLowerCase() == StatusOrder.paid.name) {
        discountExtra = DiscountExtra(
          discountName: invoice.discountExtraName,
          discountValue: invoice.discountExtraAmount,
        );
      }

      final discExt = discountExtra;

      if (discExt != null) {
        final discExtName = discExt.discountName;
        amountDiscountExtra = double.tryParse(discExt.discountValue) == null
            ? 0.0
            : double.parse(discExt.discountValue);

        if (discExtName != null && amountDiscountExtra > 0) {
          discounts.add(
            ProductDiscountModel(
              title: discExtName,
              discount: amountDiscountExtra,
            ),
          );
        }
      }

      // Set Qris Data
      if (checkQrisData != null) {
        qrisData = checkQrisData;
        isAvailablePayment = true;

        amountQrisPayment = double.tryParse(qrisData.amountQrisPayment) != null
            ? double.parse(qrisData.amountQrisPayment)
            : 0.0;
      }

      // Set Total Payment
      totalPayment = double.tryParse(invoice.totalPayment) != null
          ? double.parse(invoice.totalPayment)
          : 0.0;

      isLoading = false;
    });
  }

  void _showNotificationPoint() {
    NotificationService().show(
      title: "Kamu Keren! 😎",
      body: "Poin dari transaksi kali ini berhasil ditambahkan ke akunmu.",
      payload: GlobalEnum.showModalPoint.name,
    );
  }

  @override
  Widget build(BuildContext context) {
    double bottomInsets = 0;
    String status = 'waiting';
    if (!isLoading) {
      status = invoice.statusInvoice.toLowerCase();
      if (status == StatusOrder.paid.name) {
        bottomInsets = MediaQuery.of(context).padding.bottom;
      }
    }
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop || isLoading) return;
        Navigator.of(context).pop(popValue);
      },
      child: Scaffold(
        backgroundColor: cDark600,
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: isLoading
                ? null
                : () => Navigator.of(context).pop(popValue),
          ),
          title: const Text('Tagihan Saya'),
          centerTitle: false,
          backgroundColor: cWhite,
          foregroundColor: cDark100,
          scrolledUnderElevation: 0,
          shape: Border(bottom: BorderSide(color: cDark500)),
        ),
        bottomNavigationBar: !isLoading && status == StatusOrder.waiting.name
            ? _generateBottomNav(context)
            : const SizedBox.shrink(),
        body: isLoading
            ? Center(child: CircularProgressIndicator.adaptive())
            : Column(
                children: [
                  /// --- Reminder Discount Extra Section ---
                  if (discountExtra != null &&
                      invoice.statusInvoice.toLowerCase() ==
                          StatusOrder.waiting.name)
                    generateDiscounExtraReminderSection(),

                  /// --- Reminder Section ---
                  if (isAvailablePayment) generateReminderSection(),
                  Expanded(
                    child: RefreshIndicator.adaptive(
                      onRefresh: () => _onRefresh(),
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            /// --- Card Invoice ---
                            const SizedBox(height: 16),
                            _generateCardInvoice(),
                            const SizedBox(height: 16),

                            /// --- Card Payment ---
                            _generateCardPayment(),
                            SizedBox(height: 16 + bottomInsets),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget generateDiscounExtraReminderSection() {
    final discount = discountExtra;
    if (discount == null) return SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      color: Colors.green.shade100,
      width: double.infinity,
      child: RichText(
        text: TextSpan(
          style: TextStyle(color: Colors.black),
          children: [
            TextSpan(text: '🎉 '),
            TextSpan(text: 'Dapatkan '),
            TextSpan(
              text: '${discount.discountName} ',
              style: TextStyle(
                fontStyle: FontStyle.italic,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextSpan(text: 'dengan '),
            TextSpan(
              text: 'melunasi ',
              style: TextStyle(
                fontStyle: FontStyle.italic,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextSpan(text: 'pembayaran sebelum atau pada '),
            TextSpan(
              text: '${MyDateFormat.formatDate(discount.discountMaxDate)}.',
              style: TextStyle(
                fontStyle: FontStyle.italic,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget generateReminderSection() {
    // Calculate qris expired at
    String initialTimeString = qrisData.dateQrisPayment;
    DateTime initialTime = DateTime.parse(initialTimeString);
    DateTime endTime = initialTime.add(Duration(minutes: 30));
    String qrisExpiredAt = MyDateFormat.formatDateTime(endTime.toString());

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      color: Colors.yellow.shade700.withAlpha(180),
      width: double.infinity,
      child: RichText(
        text: TextSpan(
          style: TextStyle(color: Colors.black),
          children: [
            TextSpan(text: 'Selesaikan pembayaran sebesar '),
            TextSpan(
              text: '${CurrencyFormat().format(amount: amountQrisPayment)} ',
              style: TextStyle(
                fontStyle: FontStyle.italic,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextSpan(text: 'sebelum kadaluarsa pada '),
            TextSpan(
              text: qrisExpiredAt,
              style: TextStyle(
                fontStyle: FontStyle.italic,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Card _generateCardInvoice() {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      color: cWhite,
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16),
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
                Text('Invoices #${invoice.noInvoie}'),
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
        status == StatusOrder.waiting.name ? 'BELUM LUNAS' : 'LUNAS',
        style: TextStyle(
          color: badgeColor[1],
          fontWeight: FontWeight.bold,
          fontSize: 10,
        ),
      ),
    );
  }

  Container _sectionDetailInvoice() {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Jatuh Tempo ${MyDateFormat.formatDate(invoice.dateJatem)}',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Container(
            margin: const EdgeInsets.symmetric(vertical: 12),
            child: const Divider(height: 1, color: cDark500),
          ),
          Row(
            children: [
              Text(
                'Diterbitkan: ',
                style: TextStyle(color: cDark200, fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  MyDateFormat.formatDate(invoice.dateInvoice),
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

        Padding(
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: const Divider(height: 1, color: cDark500),
        ),

        Row(
          children: [
            const Expanded(
              child: Text(
                'Total Tagihan',
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
      ],
    );
  }

  Card _generateCardPayment() {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      color: cWhite,
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Riwayat Pembayaran',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 24),
            if (invoice.payments.isEmpty)
              const Row(children: [Text('Belum ada pembayaran.')])
            else ...[
              ListView.separated(
                itemBuilder: (context, index) {
                  final payment = invoice.payments[index];
                  final amountPayment =
                      double.tryParse(payment.amountPayment) ?? 0.0;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              payment.remarkPayment,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          Text(
                            CurrencyFormat().format(amount: amountPayment),
                            style: const TextStyle(color: Colors.green),
                          ),
                        ],
                      ),

                      const SizedBox(height: 4),

                      Text(
                        MyDateFormat.formatDateTime(
                          payment.datePayment,
                          outputFormat: 'E, dd MMM yyy - HH:mm',
                        ),
                        style: const TextStyle(color: Colors.grey),
                      ),

                      // if (payment.source.isNotEmpty) ...[
                      //   const SizedBox(height: 8),
                      //   Row(
                      //     children: [
                      //       const Icon(
                      //         Icons.payment,
                      //         size: 16,
                      //         color: Colors.blueGrey,
                      //       ),
                      //       const SizedBox(width: 6),
                      //       Text(
                      //         "Source: ${payment.source}",
                      //         style: const TextStyle(
                      //           fontSize: 13,
                      //           color: Colors.blueGrey,
                      //         ),
                      //       ),
                      //     ],
                      //   ),
                      // ],
                    ],
                  );
                },
                separatorBuilder: (context, index) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: const Divider(height: 1, color: cDark600),
                ),
                itemCount: invoice.payments.length,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: const Divider(height: 1, color: cDark500),
              ),

              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Total Dibayarkan',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        CurrencyFormat().format(amount: totalPayment),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Container _generateBottomNav(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: cWhite,
        border: Border.symmetric(
          horizontal: BorderSide(color: cDark500, width: 1),
        ),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Sisa Tagihan',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Text(
                    CurrencyFormat().format(amount: remainingInvoice),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: cPrimary200,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            isAvailablePayment
                ? Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            final willGetPoint =
                                invoice.payments.isEmpty &&
                                subTotalInvoice == amountQrisPayment;

                            Navigator.of(context)
                                .push(
                                  MaterialPageRoute(
                                    builder: (context) => QrPaymentScreen(
                                      idQrisPayment: qrisData.idQrisPayment,
                                    ),
                                  ),
                                )
                                .then((value) {
                                  if (value is Map<String, dynamic>) {
                                    final mapValue = value;
                                    final PopValue pop =
                                        mapValue['popValue'] as PopValue;

                                    if (pop == PopValue.isPaid ||
                                        pop == PopValue.needRefresh) {
                                      if (pop == PopValue.isPaid &&
                                          willGetPoint) {
                                        _showNotificationPoint();
                                      }

                                      setState(() {
                                        isLoading = true;
                                        popValue = pop;
                                      });

                                      Future.delayed(Duration(seconds: 1), () {
                                        _onRefresh();
                                      });
                                    }
                                  }
                                });
                          },
                          style: ElevatedButton.styleFrom(
                            foregroundColor: cPrimary100,
                            side: BorderSide(color: cPrimary100, width: 1),
                            padding: const EdgeInsets.symmetric(
                              vertical: 16,
                              horizontal: 24,
                            ),
                          ),
                          child: const Text(
                            "Lanjutkan Pembayaran",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  )
                : MElevatedButton(
                    onPressed: () {
                      Navigator.of(context)
                          .push(
                            MaterialPageRoute(
                              builder: (context) =>
                                  InvoicePaymentScreen(invoice: invoice),
                            ),
                          )
                          .then((value) {
                            if (value is Map<String, dynamic>) {
                              final mapValue = value;
                              final PopValue pop =
                                  mapValue['popValue'] as PopValue;
                              final bool willGetPoint =
                                  mapValue['willGetPoint'] as bool;

                              if (pop == PopValue.isPaid ||
                                  pop == PopValue.needRefresh) {
                                if (pop == PopValue.isPaid && willGetPoint) {
                                  _showNotificationPoint();
                                }

                                setState(() {
                                  isLoading = true;
                                  popValue = pop;
                                });

                                Future.delayed(Duration(seconds: 3), () {
                                  _onRefresh();
                                });
                              }
                            }
                          });
                    },
                    title: 'Buat Pembayaran',
                    isFullWidth: true,
                  ),
          ],
        ),
      ),
    );
  }
}
