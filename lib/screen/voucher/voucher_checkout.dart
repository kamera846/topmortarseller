import 'package:flutter/material.dart';
import 'package:topmortarseller/model/voucher_model.dart';
import 'package:topmortarseller/util/colors/color.dart';
import 'package:topmortarseller/util/currency_format.dart';
import 'package:topmortarseller/util/date_format.dart';
import 'package:topmortarseller/widget/form/button/elevated_button.dart';

class VoucherCheckout extends StatefulWidget {
  final List<VoucherModel> vouchers;
  final Function(VoucherModel item) toggleSelectedItem;
  const VoucherCheckout({
    super.key,
    required this.vouchers,
    required this.toggleSelectedItem,
  });

  @override
  State<VoucherCheckout> createState() => _VoucherCheckoutState();
}

class _VoucherCheckoutState extends State<VoucherCheckout> {
  late List<VoucherModel> vouchers;

  @override
  void initState() {
    super.initState();
    vouchers = widget.vouchers;
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
      body: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: vouchers.length,
        padding: const EdgeInsets.all(8),
        separatorBuilder: (context, index) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final item = vouchers[index];
          final formattedDate = MyDateFormat.formatDate(
            item.expDate,
            outputFormat: "d MMM y",
          );
          final valueVoucher = double.tryParse(item.valueVoucher) != null
              ? double.parse(item.valueVoucher)
              : 0.0;
          final foramttedValueVoucher = CurrencyFormat().format(
            amount: valueVoucher,
          );
          return Material(
            color: item.isSelected ? cPrimary400.withAlpha(50) : Colors.white,
            borderRadius: BorderRadius.circular(8),
            child: ListTile(
              selected: item.isSelected,
              onTap: () {
                widget.toggleSelectedItem(item);
                setState(() {});
              },
              leading: Icon(Icons.local_offer),
              title: Text("Voucher $foramttedValueVoucher"),
              subtitle: Text("Berlaku sampai $formattedDate"),
              trailing: Icon(
                item.isSelected ? Icons.check_circle : Icons.circle_outlined,
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
            enabled: vouchers.where((e) => e.isSelected == true).isNotEmpty,
            onPressed: () {},
            title: 'Gunakan Voucher',
            isFullWidth: true,
          ),
        ),
      ),
    );
  }
}
