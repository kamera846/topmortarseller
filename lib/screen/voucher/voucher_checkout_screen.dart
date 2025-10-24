import 'package:flutter/material.dart';
import 'package:topmortarseller/model/voucher_model.dart';
import 'package:topmortarseller/screen/voucher/voucher_product_screen.dart';
import 'package:topmortarseller/services/voucher_api.dart';
import 'package:topmortarseller/util/colors/color.dart';
import 'package:topmortarseller/util/currency_format.dart';
import 'package:topmortarseller/util/date_format.dart';
import 'package:topmortarseller/util/enum.dart';
import 'package:topmortarseller/widget/form/button/elevated_button.dart';

class VoucherCheckoutScreen extends StatefulWidget {
  final String idContact;
  final String idCart;
  const VoucherCheckoutScreen({
    super.key,
    required this.idContact,
    required this.idCart,
  });

  @override
  State<VoucherCheckoutScreen> createState() => _VoucherCheckoutScreenState();
}

class _VoucherCheckoutScreenState extends State<VoucherCheckoutScreen> {
  bool isLoading = false;

  List<VoucherModel> vouchers = [];
  List<VoucherModel> selectedVouchers = [];

  @override
  void initState() {
    super.initState();
    getVouchers();
  }

  void getVouchers() async {
    setState(() {
      isLoading = true;
    });
    await VoucherApi().list(
      idContact: widget.idContact,
      isClaimed: "1",
      onCompleted: (data) {
        setState(() {
          vouchers = data ?? [];
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
        title: Text("Pilih Beberapa Voucher"),
        centerTitle: false,
        backgroundColor: cWhite,
        foregroundColor: cDark100,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator.adaptive())
          : vouchers.isEmpty
          ? const Center(
              child: Text(
                "Belum ada voucher yang di klaim",
                textAlign: TextAlign.center,
              ),
            )
          : ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: vouchers.length,
              padding: const EdgeInsets.all(12),
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final item = vouchers[index];
                final day = MyDateFormat.formatDate(
                  item.expDate,
                  outputFormat: "d",
                );
                final month = MyDateFormat.formatDate(
                  item.expDate,
                  outputFormat: "MMM",
                );
                final year = MyDateFormat.formatDate(
                  item.expDate,
                  outputFormat: "y",
                );
                final valueVoucher = double.tryParse(item.valueVoucher) != null
                    ? double.parse(item.valueVoucher)
                    : 0.0;
                final foramttedValueVoucher = CurrencyFormat().format(
                  amount: valueVoucher,
                );
                return Material(
                  color: item.isSelected
                      ? Colors.yellow.shade800.withAlpha(50)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  child: ListTile(
                    horizontalTitleGap: 8,
                    selected: item.isSelected,
                    selectedColor: Colors.yellow.shade800,
                    onTap: () {
                      final availableItem = selectedVouchers.contains(item);
                      setState(() {
                        if (availableItem) {
                          selectedVouchers.remove(item);
                        } else {
                          selectedVouchers.add(item);
                        }
                        vouchers[index].isSelected =
                            !vouchers[index].isSelected;
                      });
                    },
                    leading: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            style: TextStyle(color: cDark100, fontSize: 12),
                            children: [
                              TextSpan(text: "EXP\n"),
                              TextSpan(
                                text: '$day\n',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              TextSpan(text: '$month $year'),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        VerticalDivider(),
                      ],
                    ),
                    title: Text(
                      "Voucher $foramttedValueVoucher",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: cDark100,
                      ),
                    ),
                    subtitle: Text(
                      "Nomor ${item.noVoucher}",
                      style: TextStyle(fontSize: 12, color: cDark100),
                    ),
                    trailing: Icon(
                      item.isSelected
                          ? Icons.check_circle
                          : Icons.circle_outlined,
                    ),
                  ),
                );
              },
            ),
      bottomNavigationBar: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border.symmetric(
            horizontal: BorderSide(color: cDark600, width: 1),
          ),
        ),
        child: SafeArea(
          child: MElevatedButton(
            enabled:
                !isLoading &&
                vouchers.isNotEmpty &&
                vouchers.where((e) => e.isSelected == true).isNotEmpty,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => VoucherProductScreen(
                    idContact: widget.idContact,
                    idCart: widget.idCart,
                    selectedVouchers: selectedVouchers,
                  ),
                ),
              ).then((value) {
                if (value is PopValue &&
                    value == PopValue.needRefresh &&
                    context.mounted) {
                  Navigator.pop(context, value);
                }
              });
            },
            title: 'Gunakan Voucher',
            isFullWidth: true,
          ),
        ),
      ),
    );
  }
}
