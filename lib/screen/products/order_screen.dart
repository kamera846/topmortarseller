import 'dart:async';

import 'package:flutter/material.dart';
import 'package:topmortarseller/model/contact_model.dart';
import 'package:topmortarseller/model/order_model.dart';
import 'package:topmortarseller/model/order_tabs_model.dart';
import 'package:topmortarseller/model/product_model.dart';
import 'package:topmortarseller/screen/products/checkout_screen.dart';
import 'package:topmortarseller/screen/products/invoice_screen.dart';
import 'package:topmortarseller/util/colors/color.dart';
import 'package:topmortarseller/util/currency_format.dart';
import 'package:topmortarseller/util/enum.dart';
import 'package:topmortarseller/widget/modal/loading_modal.dart';

class OrderScreen extends StatefulWidget {
  const OrderScreen({super.key, this.userData});

  final ContactModel? userData;

  @override
  State<OrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen>
    with TickerProviderStateMixin {
  late final TabController _tabController;
  final List<String> _tabsBadge = ['0', '0', '0', '0', '0'];
  List<OrderTabsModel> _tabsData = [];
  // ContactModel? _userData;

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
        bottom: TabBar(controller: _tabController, tabs: getTabsData()),
      ),
      backgroundColor: cDark600,
      body: TabBarView(
        controller: _tabController,
        children: _tabsData.map((item) {
          return item.body;
        }).toList(),
      ),
    );
  }

  @override
  void initState() {
    _tabController = TabController(length: 5, vsync: this);
    _getUserData();
    super.initState();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _getUserData() async {
    // // final data = widget.userData ?? await getContactModel();
    // final data = await getContactModel();
    setState(() {
      // _userData = data;
    });
  }

  List<Widget> getTabsData() {
    setState(() {
      _tabsData = [];
    });
    _tabsData.add(
      OrderTabsModel(
        header: Tab(
          icon: _tabsBadge[0] != '0'
              ? Badge(
                  label: Text(_tabsBadge[0]),
                  textColor: cWhite,
                  backgroundColor: cPrimary100,
                  child: const Icon(Icons.border_all_rounded),
                )
              : const Icon(Icons.border_all_rounded),
        ),
        body: ListOrder(
          items: (items) {
            setState(() {
              _tabsBadge[1] = items
                  .where(
                    (item) => item.orderStatus == StatusOrder.diproses.name,
                  )
                  .length
                  .toString();
              _tabsBadge[2] = items
                  .where((item) => item.orderStatus == StatusOrder.dikirim.name)
                  .length
                  .toString();
              _tabsBadge[3] = items
                  .where((item) => item.orderStatus == StatusOrder.invoice.name)
                  .length
                  .toString();
            });
            getTabsData();
          },
        ),
      ),
    );
    _tabsData.add(
      OrderTabsModel(
        header: Tab(
          icon: _tabsBadge[1] != '0'
              ? Badge(
                  label: Text(_tabsBadge[1]),
                  textColor: cWhite,
                  backgroundColor: cPrimary100,
                  child: const Icon(Icons.inventory_2_outlined),
                )
              : const Icon(Icons.inventory_2_outlined),
        ),
        body: ListOrder(
          status: StatusOrder.diproses.name,
          items: (items) => setState(() {
            _tabsBadge[1] = '${items.length}';
          }),
        ),
      ),
    );
    _tabsData.add(
      OrderTabsModel(
        header: Tab(
          icon: _tabsBadge[2] != '0'
              ? Badge(
                  label: Text(_tabsBadge[2]),
                  textColor: cWhite,
                  backgroundColor: cPrimary100,
                  child: const Icon(Icons.fire_truck_rounded),
                )
              : const Icon(Icons.fire_truck_rounded),
        ),
        body: ListOrder(
          status: StatusOrder.dikirim.name,
          items: (items) => setState(() {
            _tabsBadge[2] = '${items.length}';
          }),
        ),
      ),
    );
    _tabsData.add(
      OrderTabsModel(
        header: Tab(
          icon: _tabsBadge[3] != '0'
              ? Badge(
                  label: Text(_tabsBadge[3]),
                  textColor: cWhite,
                  backgroundColor: cPrimary100,
                  child: const Icon(Icons.payment_rounded),
                )
              : const Icon(Icons.payment_rounded),
        ),
        body: ListOrder(
          status: StatusOrder.invoice.name,
          items: (items) => setState(() {
            _tabsBadge[3] = '${items.length}';
          }),
        ),
      ),
    );
    _tabsData.add(
      OrderTabsModel(
        header: Tab(
          icon: _tabsBadge[4] != '0'
              ? Badge(
                  label: Text(_tabsBadge[4]),
                  textColor: cWhite,
                  backgroundColor: cPrimary100,
                  child: const Icon(Icons.check_circle_sharp),
                )
              : const Icon(Icons.check_circle_sharp),
        ),
        body: ListOrder(status: StatusOrder.selesai.name),
      ),
    );
    return _tabsData.map((item) {
      return item.header;
    }).toList();
  }
}

// List Order Widget
class ListOrder extends StatefulWidget {
  const ListOrder({super.key, this.status, this.items});

  final String? status;
  final Function(List<OrderModel> items)? items;

  @override
  State<ListOrder> createState() => _ListOrderState();
}

class _ListOrderState extends State<ListOrder> {
  final List<OrderModel> _items = [];
  bool _isLoading = true;
  late Timer _getItemTimer;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () => _onRefresh(),
      child: _isLoading
          ? const LoadingModal()
          : Padding(
              padding: _items.isEmpty
                  ? const EdgeInsets.all(12)
                  : const EdgeInsets.symmetric(horizontal: 12),
              child: _items.isEmpty
                  ? const Text(
                      'Belum ada pesananan',
                      textAlign: TextAlign.center,
                    )
                  : ListView.separated(
                      itemCount: _items.length,
                      separatorBuilder: (context, index) {
                        return const SizedBox(height: 12);
                      },
                      itemBuilder: (ctx, idx) {
                        var orderItem = _items[idx];
                        return Padding(
                          padding: idx == 0
                              ? const EdgeInsets.only(top: 12)
                              : idx == _items.length - 1
                              ? const EdgeInsets.only(bottom: 12)
                              : const EdgeInsets.all(0),
                          child: CardOrder(item: orderItem),
                        );
                      },
                    ),
            ),
    );
  }

  @override
  void initState() {
    _getList();
    super.initState();
  }

  @override
  void dispose() {
    _getItemTimer.cancel();
    super.dispose();
  }

  Future<void> _onRefresh() async {
    setState(() {
      _isLoading = true;
    });
    _getList();
  }

  void _getList() {
    var product1 = const ProductModel(
      idProduk: '1',
      idCity: '1',
      namaProduk: 'Thinbed',
      hargaProduk: '78000',
      imageProduk:
          'https://topmortar.com/wp-content/uploads/2021/10/TOP-THINBED-2.png',
      checkoutCount: '2',
      stok: 500,
    );
    var product2 = const ProductModel(
      idProduk: '2',
      idCity: '1',
      namaProduk: 'Plaster',
      hargaProduk: '69000',
      imageProduk:
          'https://topmortar.com/wp-content/uploads/2021/10/MOCKUP-TA-1000-x-1000.png',
      checkoutCount: '1',
      stok: 200,
    );
    _getItemTimer = Timer(const Duration(seconds: 1), () {
      setState(() {
        if (widget.status == null ||
            widget.status == StatusOrder.diproses.name) {
          _items.add(
            OrderModel(
              idOrder: '1',
              orderDate: '09 Februari 2025',
              orderStatus: StatusOrder.diproses.name,
              orderStatusColors: List.of({
                Colors.grey[400]!,
                Colors.grey[800]!,
              }),
              orderItems: List.of({
                product1.copyWith(idProduk: '1'),
                product2.copyWith(idProduk: '2'),
              }),
            ),
          );
        }
        if (widget.status == null ||
            widget.status == StatusOrder.dikirim.name) {
          _items.add(
            OrderModel(
              idOrder: '2',
              orderDate: '08 Februari 2025',
              orderStatus: StatusOrder.dikirim.name,
              orderStatusColors: List.of({
                Colors.blue[100]!,
                Colors.blue[800]!,
              }),
              orderItems: List.of({product1.copyWith(idProduk: '3')}),
            ),
          );
          _items.add(
            OrderModel(
              idOrder: '3',
              orderDate: '07 Februari 2025',
              orderStatus: StatusOrder.dikirim.name,
              orderStatusColors: List.of({
                Colors.blue[100]!,
                Colors.blue[800]!,
              }),
              orderItems: List.of({product2.copyWith(idProduk: '4')}),
            ),
          );
        }
        if (widget.status == null ||
            widget.status == StatusOrder.invoice.name) {
          _items.add(
            OrderModel(
              idOrder: '4',
              orderDate: '06 Februari 2025',
              orderStatus: StatusOrder.invoice.name,
              orderStatusColors: List.of({
                Colors.orange[100]!,
                Colors.orange[800]!,
              }),
              orderItems: List.of({
                product1.copyWith(idProduk: '5'),
                product2.copyWith(idProduk: '6'),
              }),
            ),
          );
        }
        if (widget.status == null ||
            widget.status == StatusOrder.selesai.name) {
          _items.add(
            OrderModel(
              idOrder: '5',
              orderDate: '05 Februari 2025',
              orderStatus: StatusOrder.selesai.name,
              orderStatusColors: List.of({
                Colors.green[100]!,
                Colors.green[800]!,
              }),
              orderItems: List.of({product1.copyWith(idProduk: '7')}),
            ),
          );
        }
        if (widget.items != null) {
          widget.items!(_items);
        }
        _isLoading = false;
      });
    });
  }
}

// Card Order Widget
class CardOrder extends StatelessWidget {
  const CardOrder({super.key, required this.item});

  final OrderModel item;

  String _countPrice(List<ProductModel> products) {
    var totalPrices = 0.0;
    for (var product in products) {
      totalPrices +=
          double.parse(product.hargaProduk ?? '0') *
          double.parse(product.checkoutCount ?? '0');
    }
    return CurrencyFormat().format(amount: totalPrices);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: cWhite,
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
                    const Icon(Icons.calendar_month_rounded, color: cDark200),
                    const SizedBox(width: 8),
                    Text(
                      item.orderDate,
                      style: const TextStyle(color: cDark200),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: item.orderStatusColors[0].withValues(alpha: 0.4),
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
              child: const Divider(height: 1, color: cDark500),
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
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          color: cDark600,
                          width: 50,
                          height: 50,
                          margin: const EdgeInsets.only(right: 12),
                          child: Hero(
                            tag: 'product-${product.idProduk}-${item.idOrder}',
                            child: Image.network(
                              product.imageProduk ?? '',
                              fit: BoxFit.cover,
                            ),
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
                                  fontSize: 12,
                                  color: cPrimary100,
                                ),
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
                          ),
                        ],
                      ),
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
                      Text('Total ${item.orderItems.length} produk'),
                      Text(
                        _countPrice(item.orderItems),
                        style: const TextStyle(
                          color: cPrimary100,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                if (item.orderStatus == StatusOrder.invoice.name ||
                    item.orderStatus == StatusOrder.selesai.name) ...[
                  InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (ctx) => InvoiceScreen(orderItem: item),
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: cPrimary100.withAlpha(200),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        item.orderStatus == StatusOrder.invoice.name
                            ? 'Bayar'
                            : 'Lihat Invoice',
                        style: const TextStyle(
                          color: cPrimary100,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
                InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (ctx) => CheckoutScreen(
                          items: item.orderItems,
                          orderItem: item,
                        ),
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: cPrimary100,
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
              ],
            ),
          ],
        ),
      ),
    );
  }
}
