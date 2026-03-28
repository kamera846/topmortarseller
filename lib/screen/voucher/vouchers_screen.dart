import 'package:flutter/material.dart';
import 'package:topmortarseller/screen/voucher/voucher_tab_items_future.dart';
import 'package:topmortarseller/services/voucher_api.dart';
import 'package:topmortarseller/util/colors/color.dart';

class VouchersScreen extends StatefulWidget {
  final String idContact;
  const VouchersScreen({super.key, required this.idContact});

  @override
  State<VouchersScreen> createState() => _VouchersScreenState();
}

class _VouchersScreenState extends State<VouchersScreen> {
  final VoucherApi voucherApi = VoucherApi();

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: cDark600,
        appBar: AppBar(
          title: Text("Voucher"),
          centerTitle: false,
          backgroundColor: cDark600,
          foregroundColor: cDark100,
          bottom: TabBar(
            tabs: [
              Tab(text: "Tersedia"),
              Tab(text: "Sudah di Klaim"),
            ],
          ),
        ),
        body: TabBarView(
          physics: const NeverScrollableScrollPhysics(),
          children: [
            VoucherTabItemsFuture(
              fetchItems: () =>
                  voucherApi.fetchListVoucher(idContact: widget.idContact),
            ),
            VoucherTabItemsFuture(
              fetchItems: () => voucherApi.fetchListVoucher(
                idContact: widget.idContact,
                isClaimed: true,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
