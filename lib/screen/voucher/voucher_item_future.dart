import 'package:flutter/material.dart';
import 'package:topmortarseller/model/voucher_model.dart';
import 'package:topmortarseller/services/voucher_api.dart';
import 'package:topmortarseller/util/date_format.dart';
import 'package:topmortarseller/widget/modal/modal_action.dart';
import 'package:topmortarseller/widget/snackbar/show_snackbar.dart';

class VoucherTabItemsFuture extends StatefulWidget {
  final Future<List<VoucherModel>> Function() fetchItems;
  const VoucherTabItemsFuture({super.key, required this.fetchItems});

  @override
  State<VoucherTabItemsFuture> createState() => _VoucherTabItemsFutureState();
}

class _VoucherTabItemsFutureState extends State<VoucherTabItemsFuture> {
  late Future<List<VoucherModel>> futureItems;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    futureItems = widget.fetchItems();
  }

  Future<void> handleRefresh() async {
    setState(() {
      futureItems = widget.fetchItems();
    });
  }

  void showClaimValidation(VoucherModel item) {
    showAdaptiveDialog(
      context: context,
      builder: (context) {
        return AlertDialog.adaptive(
          title: Text("Klaim Voucher"),
          content: Text(
            "Apakah anda yakin akan klaim voucher nomor ${item.noVoucher} sekarang?",
          ),
          actions: [
            ModalAction.adaptiveAction(
              context: context,
              onPressed: () => Navigator.pop(context),
              child: const Text("Batal"),
            ),
            ModalAction.adaptiveAction(
              context: context,
              onPressed: () {
                Navigator.pop(context);
                handleClaimItem(item);
              },
              child: const Text("Klaim Sekarang"),
            ),
          ],
        );
      },
    );
  }

  void handleClaimItem(VoucherModel item) {
    setState(() {
      isLoading = true;
    });

    VoucherApi().claim(
      idVoucher: item.idVoucher,
      onError: (e) => showSnackBar(context, e),
      onSuccess: (e) => showSnackBar(context, e),
      onCompleted: (data) {
        setState(() {
          isLoading = false;
          futureItems = widget.fetchItems();
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator.adaptive(
      onRefresh: handleRefresh,
      child: FutureBuilder<List<VoucherModel>>(
        future: futureItems,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting ||
              isLoading) {
            return const Center(child: CircularProgressIndicator.adaptive());
          }
          if (snapshot.hasError) {
            String errorMessage = snapshot.error.toString().replaceFirst(
              'Exception: ',
              '',
            );
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(errorMessage, textAlign: TextAlign.center),
                  TextButton(
                    onPressed: handleRefresh,
                    child: Text("Muat Ulang"),
                  ),
                ],
              ),
            );
          }
          if (snapshot.hasData && snapshot.data!.isNotEmpty) {
            final items = snapshot.data!;
            return ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: items.length,
              separatorBuilder: (context, index) => Divider(),
              itemBuilder: (context, index) {
                final item = items[index];
                final formattedDate = MyDateFormat.formatDate(
                  item.expDate,
                  outputFormat: "d-M-y",
                );
                return ListTile(
                  leading: Icon(Icons.local_offer),
                  title: Text("Voucher ${item.noVoucher}"),
                  subtitle: Text("Berlaku sampai $formattedDate"),
                  trailing: FilledButton(
                    onPressed: item.isClaimed == "1"
                        ? null
                        : () => showClaimValidation(item),
                    child: Text("Klaim"),
                  ),
                );
              },
            );
          }
          return const Center(child: Text("Belum ada voucher"));
        },
      ),
    );
  }
}
