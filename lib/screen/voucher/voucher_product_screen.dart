import 'package:flutter/material.dart';
import 'package:topmortarseller/model/product_model.dart';
import 'package:topmortarseller/model/voucher_model.dart';
import 'package:topmortarseller/services/cart_api.dart';
import 'package:topmortarseller/services/product_api.dart';
import 'package:topmortarseller/util/colors/color.dart';
import 'package:topmortarseller/util/currency_format.dart';
import 'package:topmortarseller/util/enum.dart';
import 'package:topmortarseller/widget/form/button/elevated_button.dart';
import 'package:topmortarseller/widget/modal/modal_action.dart';
import 'package:topmortarseller/widget/snackbar/show_snackbar.dart';

class VoucherProductScreen extends StatefulWidget {
  final String idContact;
  final String idCart;
  final List<VoucherModel> selectedVouchers;
  const VoucherProductScreen({
    super.key,
    required this.idContact,
    required this.idCart,
    required this.selectedVouchers,
  });

  @override
  State<VoucherProductScreen> createState() => _VoucherProductScreenState();
}

class _VoucherProductScreenState extends State<VoucherProductScreen> {
  bool isLoading = false;

  double totalValueVouchers = 0.0;
  double totalValueProducts = 0.0;
  String formattedTotalValueVouchers = "";
  String formattedTotalValueProducts = "";

  late List<ProductModel> products;
  List<ProductModel> selectedProducts = [];

  @override
  void initState() {
    super.initState();
    for (var voucher in widget.selectedVouchers) {
      final valueVoucher = double.tryParse(voucher.valueVoucher) != null
          ? double.parse(voucher.valueVoucher)
          : 0.0;
      totalValueVouchers += valueVoucher;
      formattedTotalValueVouchers = CurrencyFormat().format(
        amount: totalValueVouchers,
      );
    }
    getProducts();
  }

  void getProducts() async {
    setState(() {
      isLoading = true;
    });
    await ProductApiService().list(
      idContact: widget.idContact,
      onCompleted: (data) {
        setState(() {
          products = data;
          isLoading = false;
        });
      },
    );
  }

  void handleMinusItem(ProductModel product) {
    setState(() {
      product.voucherQty--;
    });
  }

  void handlePlusItem(ProductModel product) {
    setState(() {
      product.voucherQty++;
    });
  }

  String valueProductsCounter() {
    totalValueProducts = 0.0;
    for (var product in products) {
      final availableItem = selectedProducts.contains(product);

      if (availableItem && product.voucherQty < 1) {
        selectedProducts.remove(product);
      } else if (!availableItem && product.voucherQty > 0) {
        selectedProducts.add(product);
      }

      final productPrice = double.tryParse(product.hargaProduk ?? "0.0") != null
          ? double.parse(product.hargaProduk ?? "0.0")
          : 0.0;
      totalValueProducts += productPrice * product.voucherQty;
    }
    return CurrencyFormat().format(amount: totalValueProducts);
  }

  void submitProcess() {
    final List<int> vouchersPayload = widget.selectedVouchers
        .map((e) => int.parse(e.idVoucher))
        .toList();
    final List<Map<String, int>> productsPayload = [];
    String selectedProductsText = "";
    for (var i = 0; i < selectedProducts.length; i++) {
      final product = selectedProducts[i];
      final payloadObject = {
        "id": int.parse(product.idProduk ?? "-1"),
        "pcs": product.voucherQty,
      };
      productsPayload.add(payloadObject);
      selectedProductsText +=
          "${i + 1}. ${product.namaProduk} (${product.voucherQty} pcs)\n";
    }

    showAdaptiveDialog(
      context: context,
      builder: (context) {
        return AlertDialog.adaptive(
          title: Text("Penukaran Voucher"),
          content: Text(
            "Voucher akan ditukarkan dengan produk berikut:\n\n$selectedProductsText",
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
                fetchApplyVoucher(
                  idCart: widget.idCart,
                  idVouchers: vouchersPayload,
                  idProducts: productsPayload,
                );
              },
              child: const Text('Lanjutkan'),
            ),
          ],
        );
      },
    );
  }

  void fetchApplyVoucher({
    required String idCart,
    required List<int> idVouchers,
    required List<Map<String, int>> idProducts,
  }) async {
    setState(() {
      isLoading = true;
    });
    await CartApiService().applyVoucher(
      idCart: idCart,
      idVouchers: idVouchers,
      idProducts: idProducts,
      onError: (e) => showSnackBar(context, e),
      onCompleted: (status) {
        setState(() {
          isLoading = false;
        });
        if (status) {
          Navigator.pop(context, PopValue.needRefresh);
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: cDark600,
      appBar: AppBar(
        title: Text("Pilih Produk"),
        centerTitle: false,
        backgroundColor: cWhite,
        foregroundColor: cDark100,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator.adaptive())
          : products.isEmpty
          ? const Center(
              child: Text("Produk kosong", textAlign: TextAlign.center),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text(
                    "Total nilai voucher anda $formattedTotalValueVouchers",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text(
                    "Total nilai produk yang dipilih ${valueProductsCounter()}",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                ListView.separated(
                  shrinkWrap: true,
                  itemCount: products.length,
                  padding: const EdgeInsets.all(12),
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final item = products[index];
                    final price = item.hargaProduk ?? "0.0";
                    final productPrice = double.tryParse(price) != null
                        ? double.parse(price)
                        : 0.0;
                    final foramttedProductPrice = CurrencyFormat().format(
                      amount: productPrice,
                    );
                    return Material(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      child: ListTile(
                        contentPadding: EdgeInsets.symmetric(horizontal: 12),
                        title: Text(
                          "${item.namaProduk}",
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Text(foramttedProductPrice),
                        leading: ClipRRect(
                          borderRadius: BorderRadiusGeometry.circular(6),
                          child: Image.network(
                            item.imageProduk ?? 'https://google.com',
                            key: Key(item.idProduk ?? '-1'),
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return const Icon(
                                Icons.error,
                                size: 20,
                                color: Colors.grey,
                              );
                            },
                          ),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              onPressed: item.voucherQty <= 0
                                  ? null
                                  : () => handleMinusItem(item),
                              icon: Icon(Icons.remove_circle),
                            ),
                            Text(
                              "${item.voucherQty}",
                              style: TextStyle(fontSize: 16),
                            ),
                            IconButton(
                              onPressed: () => handlePlusItem(item),
                              icon: Icon(Icons.add_circle),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
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
                selectedProducts.isNotEmpty &&
                totalValueProducts <= totalValueVouchers,
            onPressed: submitProcess,
            title: 'OK',
            isFullWidth: true,
          ),
        ),
      ),
    );
  }
}
