import 'package:flutter/material.dart';
import 'package:topmortarseller/model/voucher_model.dart';
import 'package:topmortarseller/util/colors/color.dart';
import 'package:topmortarseller/util/date_format.dart';
import 'package:topmortarseller/widget/form/button/elevated_button.dart';

class VoucherCheckout extends StatefulWidget {
  final List<VoucherModel> vouchers;
  const VoucherCheckout({super.key, required this.vouchers});

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
        separatorBuilder: (context, index) => Divider(height: 1),
        itemBuilder: (context, index) {
          final item = vouchers[index];
          final formattedDate = MyDateFormat.formatDate(
            item.expDate,
            outputFormat: "d MMM y",
          );
          return ListTile(
            selected: item.isSelected,
            onTap: () {
              setState(() {
                vouchers[index].isSelected = !vouchers[index].isSelected;
              });
            },
            leading: Icon(Icons.local_offer),
            title: Text("Voucher ${item.noVoucher}"),
            subtitle: Text("Berlaku sampai $formattedDate"),
            trailing: Icon(
              item.isSelected ? Icons.check_circle : Icons.circle_outlined,
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
            onPressed: () {},
            title: 'Gunakan Voucher',
            isFullWidth: true,
          ),
        ),
      ),
    );
  }
}
