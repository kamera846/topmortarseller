import 'package:flutter/material.dart';
import 'package:topmortarseller/model/contact_model.dart';
import 'package:topmortarseller/model/order_model.dart';
import 'package:topmortarseller/model/product_model.dart';
import 'package:topmortarseller/util/colors/color.dart';
import 'package:topmortarseller/util/currency_format.dart';
import 'package:topmortarseller/widget/modal/loading_modal.dart';

class OrderScreen extends StatefulWidget {
  const OrderScreen({
    super.key,
    this.userData,
  });

  final ContactModel? userData;

  @override
  State<OrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  ContactModel? _userData;
  List<OrderModel> _items = [];
  bool _isLoading = true;

  @override
  void initState() {
    _getUserData();
    super.initState();
  }

  void _getUserData() async {
    final data = widget.userData ?? await getContactModel();
    setState(() {
      _userData = data;
    });

    _getList();
  }

  void _getList() async {
    var product1 = const ProductModel(
        idProduk: '1',
        idCity: '1',
        namaProduk: 'Thinbed',
        hargaProduk: '78000',
        imageProduk:
            'https://topmortar.com/wp-content/uploads/2021/10/TOP-THINBED-2.png',
        checkoutCount: '2',
        stok: 500);
    var product2 = const ProductModel(
        idProduk: '2',
        idCity: '1',
        namaProduk: 'Plaster',
        hargaProduk: '69000',
        imageProduk:
            'https://topmortar.com/wp-content/uploads/2021/10/MOCKUP-TA-1000-x-1000.png',
        checkoutCount: '1',
        stok: 200);
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        _items.add(OrderModel(
            orderDate: '09 Februari 2025',
            orderStatus: 'sedang diproses',
            orderStatusColors: List.of({Colors.grey[400]!, Colors.grey[800]!}),
            orderItems: List.of({product1, product2})));
        _items.add(OrderModel(
            orderDate: '08 Februari 2025',
            orderStatus: 'dalam perjalanan',
            orderStatusColors: List.of({Colors.blue[100]!, Colors.blue[800]!}),
            orderItems: List.of({product1})));
        _items.add(OrderModel(
            orderDate: '07 Februari 2025',
            orderStatus: 'dalam perjalanan',
            orderStatusColors: List.of({Colors.blue[100]!, Colors.blue[800]!}),
            orderItems: List.of({product2})));
        _items.add(OrderModel(
            orderDate: '06 Februari 2025',
            orderStatus: 'belum lunas',
            orderStatusColors:
                List.of({Colors.orange[100]!, Colors.orange[800]!}),
            orderItems: List.of({product1, product2})));
        _items.add(OrderModel(
            orderDate: '05 Februari 2025',
            orderStatus: 'lunas',
            orderStatusColors:
                List.of({Colors.green[100]!, Colors.green[800]!}),
            orderItems: List.of({product1})));
        _isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Pesanan Saya'),
        centerTitle: false,
        backgroundColor: cDark600,
        foregroundColor: cDark100,
      ),
      backgroundColor: cDark600,
      body: _isLoading
          ? const LoadingModal()
          : Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
              ),
              child: ListView.builder(
                itemCount: _items.length,
                itemBuilder: (ctx, idx) {
                  var orderItem = _items[idx];
                  return CardOrder(item: orderItem);
                },
              ),
            ),
    );
  }
}

class CardOrder extends StatelessWidget {
  const CardOrder({super.key, required this.item});

  final OrderModel item;

  String _countPrice(List<ProductModel> products) {
    var totalPrices = 0.0;
    for (var product in products) {
      totalPrices += double.parse(product.hargaProduk ?? '0') *
          double.parse(product.checkoutCount ?? '0');
    }
    return CurrencyFormat().format(amount: totalPrices);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: cWhite,
      margin: const EdgeInsets.only(bottom: 12),
      clipBehavior: Clip.antiAliasWithSaveLayer,
      elevation: 0,
      shadowColor: cDark600,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.calendar_month_rounded,
                      color: cDark200,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      item.orderDate,
                      style: const TextStyle(color: cDark200),
                    ),
                  ],
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: item.orderStatusColors[0].withOpacity(0.4),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    item.orderStatus.toUpperCase(),
                    style: TextStyle(
                      color: item.orderStatusColors[1],
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                    ),
                  ),
                ),
              ],
            ),
            Container(
              margin: const EdgeInsets.symmetric(vertical: 12),
              child: const Divider(
                height: 1,
                color: cDark500,
              ),
            ),
            ListView.builder(
              shrinkWrap: true,
              itemCount: item.orderItems.length,
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                final product = item.orderItems[index];
                return Container(
                  width: double.infinity,
                  height: 50,
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    children: [
                      Container(
                        width: 50,
                        margin: const EdgeInsets.only(right: 12),
                        decoration: BoxDecoration(
                          color: cDark600,
                          borderRadius: BorderRadius.circular(8),
                          image: DecorationImage(
                            image: NetworkImage(
                              product.imageProduk ?? '',
                            ),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            product.namaProduk ?? '',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Row(
                            children: [
                              Text(
                                '${CurrencyFormat().format(amount: double.parse(product.hargaProduk ?? '0'))} (${product.checkoutCount}x)',
                                style: const TextStyle(
                                    fontSize: 12, color: cPrimary100),
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                'Rp 100.000',
                                style: TextStyle(
                                  fontSize: 12,
                                  decoration: TextDecoration.lineThrough,
                                ),
                              ),
                            ],
                          )
                        ],
                      )
                    ],
                  ),
                );
              },
            ),
            Row(
              // mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Total ${item.orderItems.length} produk',
                      ),
                      Text(
                        _countPrice(item.orderItems),
                        style: const TextStyle(
                            color: cPrimary100, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                if (item.orderStatus == 'belum lunas' ||
                    item.orderStatus == 'lunas') ...[
                  InkWell(
                    onTap: () {},
                    child: Material(
                      color: Colors.transparent,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.transparent,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: cPrimary100.withAlpha(200),
                            width: 1,
                          ),
                        ),
                        child: const Text(
                          'Lihat Invoice',
                          style: TextStyle(
                            color: cPrimary100,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 8),
                ],
                InkWell(
                  onTap: () {},
                  splashColor: cDark100,
                  child: Material(
                    color: Colors.transparent,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 6),
                      decoration: BoxDecoration(
                        color: cPrimary100.withAlpha(200),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        'Detail Pesanan',
                        style: TextStyle(
                          color: cWhite,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
