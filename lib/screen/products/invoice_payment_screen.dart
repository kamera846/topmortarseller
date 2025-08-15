import 'package:flutter/material.dart';
import 'package:topmortarseller/model/invoice_model.dart';
import 'package:topmortarseller/services/invoice_api.dart';
import 'package:topmortarseller/services/notification_service.dart';
import 'package:topmortarseller/util/colors/color.dart';
import 'package:topmortarseller/util/currency_format.dart';
import 'package:topmortarseller/util/enum.dart';
import 'package:topmortarseller/widget/form/button/elevated_button.dart';
import 'package:topmortarseller/widget/form/textfield/text_field.dart';
import 'package:topmortarseller/widget/modal/loading_modal.dart';
import 'package:topmortarseller/widget/modal/modal_action.dart';
import 'package:topmortarseller/widget/snackbar/show_snackbar.dart';

class InvoicePaymentScreen extends StatefulWidget {
  final InvoiceModel invoice;

  const InvoicePaymentScreen({super.key, required this.invoice});

  @override
  State<InvoicePaymentScreen> createState() => _InvoicePaymentScreenState();
}

enum PaymentType { full, partial }

class _InvoicePaymentScreenState extends State<InvoicePaymentScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _amountController = TextEditingController();
  String? _amountErrorText;
  PaymentType _selectedPaymentType = PaymentType.full;
  double _totalInvoice = 0.0;
  double _paidAmount = 0.0;
  double _remainingPaidAmount = 0.0;
  bool isAvailablePoin = false;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    final invoice = widget.invoice;
    _totalInvoice = double.tryParse(invoice.totalInvoice) != null
        ? double.parse(invoice.totalInvoice)
        : 0.0;
    _paidAmount = double.tryParse(invoice.totalPayment) != null
        ? double.parse(invoice.totalPayment)
        : 0.0;
    _remainingPaidAmount = double.tryParse(invoice.sisaInvoice) != null
        ? double.parse(invoice.sisaInvoice)
        : 0.0;
    _amountController.text = _totalInvoice.toStringAsFixed(0);
    isAvailablePoin = invoice.payments.isEmpty;
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _onPaymentTypeChanged(PaymentType type) {
    setState(() {
      _selectedPaymentType = type;
      if (type == PaymentType.full) {
        _amountController.text = _totalInvoice.toStringAsFixed(0);
      } else {
        _amountErrorText = null;
        _amountController.clear();
      }
    });
  }

  void _proceedToPayment() {
    double paymentAmount;
    if (_selectedPaymentType == PaymentType.full) {
      paymentAmount = _remainingPaidAmount;
    } else {
      if (_formKey.currentState!.validate()) {
        if (_amountController.text.isEmpty) {
          setState(() {
            _amountErrorText = 'Nominal tidak boleh kosong';
          });
          return;
        }
        final amount = double.tryParse(_amountController.text);
        if (amount == null || amount <= 0) {
          setState(() {
            _amountErrorText = 'Nominal harus lebih dari nol';
          });
          return;
        }
        if (amount > _remainingPaidAmount) {
          setState(() {
            _amountErrorText = 'Nominal tidak boleh melebihi sisa tagihan';
          });
          return;
        }
        paymentAmount = double.parse(_amountController.text);
      } else {
        return;
      }
    }

    showAdaptiveDialog(
      context: context,
      builder: (context) {
        return AlertDialog.adaptive(
          title: Text('Konfirmasi'),
          content: Text(
            'Lanjutkan pembayaran dengan nominal ${CurrencyFormat().format(amount: paymentAmount)}?',
          ),
          actions: <Widget>[
            ModalAction.adaptiveAction(
              context: context,
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            ModalAction.adaptiveAction(
              context: context,
              onPressed: () {
                Navigator.pop(context);
                _submitPaid(paymentAmount);
              },
              child: const Text('Ya'),
            ),
          ],
        );
      },
    );

    // Tampilkan QRIS dengan nominal yang sudah ditentukan
    // showModalBottomSheet(
    //   context: context,
    //   isScrollControlled: true,
    //   backgroundColor: Colors.transparent,
    //   builder: (context) => QrisBottomSheet(
    //     paymentAmount: paymentAmount,
    //     invoiceId: widget.invoice.idInvoice,
    //   ),
    // );
  }

  Future<void> _submitPaid(double paymentAmount) async {
    if (isAvailablePoin && _selectedPaymentType == PaymentType.full) {
      NotificationService().show(
        title: "Wahh!, Kamu Keren 😎",
        body: "Poin berhasil ditambahkan ke akunmu.",
      );
    }
    // setState(() {
    //   isLoading = true;
    // });
    // await InvoiceApi().payment(
    //   idInvoice: widget.invoice.idInvoice,
    //   amount: paymentAmount.toString(),
    //   onError: (e) {
    //     showSnackBar(context, e);
    //     setState(() => isLoading = false);
    //   },
    //   onSuccess: (e) {
    //     showSnackBar(context, e);
    //     Navigator.pop(context, PopValue.isPaid);
    //   },
    //   onCompleted: () {
    //     if (isAvailablePoin && _selectedPaymentType == PaymentType.full) {
    //       NotificationService().show(
    //         title: "Keren! Kamu dapat poin tambahan 🎉",
    //         body: "Cek sekarang dan raih lebih banyak keuntungan.",
    //       );
    //     }
    //   },
    // );
  }

  @override
  Widget build(BuildContext context) {
    final invoice = widget.invoice;

    return PopScope(
      canPop: !isLoading,
      child: Scaffold(
        backgroundColor: cDark600,
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: isLoading ? null : () => Navigator.of(context).pop(),
          ),
          title: const Text('Pembayaran Tagihan'),
          centerTitle: false,
          backgroundColor: cWhite,
          foregroundColor: cDark100,
          scrolledUnderElevation: 0,
          shape: Border(bottom: BorderSide(color: cDark500)),
        ),
        body: Stack(
          children: [
            Positioned.fill(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Bagian Ringkasan Invoice
                      _buildInvoiceSummary(invoice),
                      const SizedBox(height: 24),
                      const Text(
                        'Pilih Metode Pembayaran',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Opsi Pembayaran Penuh
                      _buildPaymentOptionCard(
                        title:
                            'Bayar Lunas ${isAvailablePoin ? '(+poin)' : ''}',
                        subtitle:
                            'Bayar sisa tagihan sebesar ${CurrencyFormat().format(amount: _remainingPaidAmount)}',
                        value: PaymentType.full,
                        isSelected: _selectedPaymentType == PaymentType.full,
                        onTap: () => _onPaymentTypeChanged(PaymentType.full),
                      ),
                      const SizedBox(height: 16),
                      // Opsi Pembayaran Sebagian
                      _buildPaymentOptionCard(
                        title: 'Bayar Sebagian (Cicilan)',
                        subtitle:
                            'Masukkan nominal pembayaran sesuai keinginan',
                        value: PaymentType.partial,
                        isSelected: _selectedPaymentType == PaymentType.partial,
                        onTap: () => _onPaymentTypeChanged(PaymentType.partial),
                      ),
                      const SizedBox(height: 16),
                      _buildSelectedOptionDetail(),
                    ],
                  ),
                ),
              ),
            ),
            isLoading
                ? const Positioned.fill(child: LoadingModal())
                : const Positioned.fill(child: SizedBox.shrink()),
          ],
        ),
        bottomNavigationBar: !isLoading
            ? Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: const BoxDecoration(
                  color: cWhite,
                  border: Border.symmetric(
                    horizontal: BorderSide(color: cDark500, width: 1),
                  ),
                ),
                child: SafeArea(
                  child: MElevatedButton(
                    onPressed: _proceedToPayment,
                    title: 'Lanjutkan Pembayaran',
                    isFullWidth: true,
                  ),
                ),
              )
            : const SizedBox.shrink(),
      ),
    );
  }

  Widget _buildInvoiceSummary(InvoiceModel invoice) {
    return Container(
      decoration: BoxDecoration(
        color: cWhite,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: cDark500, width: 1),
        boxShadow: [
          BoxShadow(
            color: cDark600.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Invoice #${invoice.noInvoie}',
              style: const TextStyle(color: cDark200),
            ),
            const Divider(color: cDark500),
            _buildSummaryRow('Total Tagihan', _totalInvoice),
            _buildSummaryRow('Sudah Dibayar', _paidAmount),
            _buildSummaryRow(
              'Sisa Tagihan',
              _remainingPaidAmount,
              isHighlight: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(
    String label,
    double amount, {
    bool isHighlight = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: isHighlight ? FontWeight.bold : FontWeight.normal,
              color: isHighlight ? cPrimary200 : cDark100,
            ),
          ),
          Text(
            CurrencyFormat().format(amount: amount),
            style: TextStyle(
              fontWeight: isHighlight ? FontWeight.bold : FontWeight.normal,
              color: isHighlight ? cPrimary200 : cDark100,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentOptionCard({
    required String title,
    required String subtitle,
    required PaymentType value,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        color: isSelected ? cPrimary600.withValues(alpha: 0.1) : cWhite,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isSelected ? cPrimary200 : cDark500,
          width: 1,
        ),
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: cPrimary200.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Radio<PaymentType>(
                value: value,
                groupValue: _selectedPaymentType,
                onChanged: (PaymentType? value) => onTap(),
                activeColor: cPrimary200,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isSelected ? cPrimary200 : cDark100,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: isSelected ? cPrimary200 : cDark300,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSelectedOptionDetail() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_selectedPaymentType == PaymentType.full && isAvailablePoin) ...[
          const Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(Icons.info_outline, size: 20, color: cDark200),
              SizedBox(width: 8),
              Text(
                'Bonus Poin Aplikasi',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: cWhite,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: cDark500, width: 1),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: RichText(
                text: TextSpan(
                  style: TextStyle(color: cDark200),
                  children: [
                    TextSpan(
                      text:
                          'Dapatkan poin aplikasi dengan menggunakan opsi pembayaran',
                    ),
                    TextSpan(
                      style: TextStyle(
                        color: cDark100,
                        fontStyle: FontStyle.italic,
                      ),
                      text: ' Bayar lunas (+poin)',
                    ),
                    TextSpan(text: '.\n\n'),
                    TextSpan(
                      text:
                          'Bonus poin tidak berlaku jika sebelumnya anda sudah pernah menggunakan opsi pembayaran',
                    ),
                    TextSpan(
                      style: TextStyle(
                        color: cDark100,
                        fontStyle: FontStyle.italic,
                      ),
                      text: ' Bayar Sebagian (Cicilan) ',
                    ),
                    TextSpan(text: 'di invoice ini.\n\n'),
                    TextSpan(
                      text: 'Catatan: Bonus poin berlaku di setiap invoice.',
                    ),
                  ],
                ),
              ),
            ),
          ),
        ] else if (_selectedPaymentType == PaymentType.partial) ...[
          const Text(
            'Isi Nominal Pembayaran',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          // TextFormField(
          //   controller: _amountController,
          //   keyboardType: TextInputType.number,
          //   decoration: InputDecoration(
          //     labelText: 'Nominal',
          //     prefixText: 'Rp. '
          //   ),
          // ),
          MTextField(
            controller: _amountController,
            label: 'Nominal',
            prefixText: 'Rp. ',
            keyboardType: TextInputType.number,
            errorText: _amountErrorText,
            onChanged: (String value) {
              setState(() {
                _amountErrorText = null;
              });
            },
          ),
        ],
      ],
    );
  }
}

// --- Widget untuk Modal QRIS ---
class QrisBottomSheet extends StatelessWidget {
  final double paymentAmount;
  final String invoiceId;

  const QrisBottomSheet({
    super.key,
    required this.paymentAmount,
    required this.invoiceId,
  });

  @override
  Widget build(BuildContext context) {
    // Simulasi QR Code
    final qrisData = 'InvoiceID:$invoiceId|Amount:$paymentAmount';

    // Asumsi ada package untuk QR code, contoh: qrcode_flutter atau qr_flutter
    // Misalnya, menggunakan Image.network dari API QR code generator
    final qrImageUrl =
        'https://api.qrserver.com/v1/create-qr-code/?size=250x250&data=$qrisData';

    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.9,
      builder: (_, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: SafeArea(
            child: ListView(
              controller: scrollController,
              padding: const EdgeInsets.all(24),
              children: [
                Center(
                  child: Container(
                    width: 60,
                    height: 6,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Pembayaran QRIS',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Total Pembayaran: ${CurrencyFormat().format(amount: paymentAmount)}',
                  style: const TextStyle(fontSize: 18, color: cPrimary200),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                Center(
                  child: Image.network(
                    qrImageUrl,
                    width: 250,
                    height: 250,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return const CircularProgressIndicator();
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return const Text('Gagal memuat QR Code');
                    },
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Scan QR Code di atas dengan aplikasi pembayaran Anda untuk menyelesaikan transaksi.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: cDark300),
                ),
                const SizedBox(height: 32),
                ElevatedButton.icon(
                  onPressed: () {
                    // Logika untuk mencetak/menyimpan QR code
                    // Contoh: show a success message
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Coming soon!')),
                    );
                  },
                  icon: const Icon(Icons.print),
                  label: const Text(
                    'Cetak QRIS',
                    style: TextStyle(fontSize: 16),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
