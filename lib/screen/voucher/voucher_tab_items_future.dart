import 'package:flutter/material.dart';
import 'package:topmortarseller/model/voucher_model.dart';
import 'package:topmortarseller/screen/products/catalog_screen.dart';
import 'package:topmortarseller/services/voucher_api.dart';
import 'package:topmortarseller/util/colors/color.dart';
import 'package:topmortarseller/util/currency_format.dart';
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
    final valueVoucher = double.tryParse(item.valueVoucher) != null
        ? double.parse(item.valueVoucher)
        : 0.0;
    final foramttedValueVoucher = CurrencyFormat().format(amount: valueVoucher);
    final formattedDate = MyDateFormat.formatDate(
      item.expDate,
      outputFormat: "d MMM y",
    );
    showAdaptiveDialog(
      context: context,
      builder: (context) {
        return AlertDialog.adaptive(
          title: Text("Klaim Voucher"),
          content: Text(
            "Voucher $foramttedValueVoucher nomor ${item.noVoucher}. Berlaku sampai $formattedDate ",
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
              padding: const EdgeInsets.all(12),
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final item = items[index];
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
                      ? cPrimary400.withAlpha(50)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  child: ListTile(
                    horizontalTitleGap: 8,
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
                      ),
                    ),
                    subtitle: Text(
                      "Nomor ${item.noVoucher}",
                      style: TextStyle(fontSize: 12),
                    ),
                    trailing: item.isClaimed == "0"
                        ? FilledButton(
                            onPressed: () => showClaimValidation(item),
                            child: Text(
                              "Klaim",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          )
                        : FilledButton(
                            style: FilledButton.styleFrom(
                              backgroundColor: Colors.yellow.shade800.withAlpha(
                                50,
                              ),
                              foregroundColor: Colors.yellow.shade800,
                            ),
                            onPressed: () {
                              Navigator.pop(context);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const CatalogScreen(),
                                ),
                              );
                            },
                            child: Text(
                              "Gunakan",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
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
