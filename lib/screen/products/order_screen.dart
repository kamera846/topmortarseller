import 'dart:async';

import 'package:flutter/material.dart';
import 'package:topmortarseller/model/contact_model.dart';
import 'package:topmortarseller/model/order_model.dart';
import 'package:topmortarseller/model/order_tabs_model.dart';
import 'package:topmortarseller/screen/products/order_detail_screen.dart';
import 'package:topmortarseller/services/app_order_api.dart';
import 'package:topmortarseller/util/colors/color.dart';
import 'package:topmortarseller/util/currency_format.dart';
import 'package:topmortarseller/util/date_format.dart';
import 'package:topmortarseller/util/enum.dart';
import 'package:topmortarseller/widget/modal/loading_modal.dart';
import 'package:topmortarseller/widget/snackbar/show_snackbar.dart';

class OrderScreen extends StatefulWidget {
  const OrderScreen({super.key, this.userData});

  final ContactModel? userData;

  @override
  State<OrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen>
    with TickerProviderStateMixin {
  late final TabController _tabController;
  final List<String> _tabsBadge = ['0', '0', '0', '0'];
  final List<String> _tabsTitle = [
    'Pesanan Saya',
    'Pesanan Diproses',
    'Pesanan Dikirim',
    'Pesanan Selesai',
  ];
  List<OrderTabsModel> _tabsData = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(_tabsTitle[_tabController.index]),
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
    _tabController = TabController(length: 4, vsync: this);
    super.initState();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<Widget> getTabsData() {
    setState(() {
      _tabsData = [];
    });
    // Tab ALL
    _tabsData.add(
      OrderTabsModel(
        header: Tab(icon: Icon(Icons.border_all_rounded)),
        body: ListOrder(
          items: (items) {
            setState(() {
              _tabsBadge[0] = items.length.toString();
              _tabsBadge[1] = items
                  .where(
                    (item) =>
                        item.statusAppOrder.toLowerCase() ==
                        StatusOrder.diproses.name,
                  )
                  .length
                  .toString();
              _tabsBadge[2] = items
                  .where(
                    (item) =>
                        item.statusAppOrder.toLowerCase() ==
                        StatusOrder.dikirim.name,
                  )
                  .length
                  .toString();
              _tabsBadge[3] = items
                  .where(
                    (item) =>
                        item.statusAppOrder.toLowerCase() ==
                        StatusOrder.selesai.name,
                  )
                  .length
                  .toString();
            });
            getTabsData();
          },
        ),
      ),
    );
    // Tab DIPROSES
    _tabsData.add(
      OrderTabsModel(
        header: Tab(
          icon: _tabsBadge[1] != '0'
              ? Badge(
                  label: Text(_tabsBadge[1]),
                  textColor: cWhite,
                  backgroundColor: cPrimary100,
                  child: Icon(
                    _tabController.index == 1
                        ? Icons.inventory
                        : Icons.inventory_2_outlined,
                  ),
                )
              : Icon(
                  _tabController.index == 1
                      ? Icons.inventory
                      : Icons.inventory_2_outlined,
                ),
        ),
        body: ListOrder(
          status: StatusOrder.diproses.name,
          items: (items) => setState(() {
            _tabsBadge[1] = '${items.length}';
          }),
        ),
      ),
    );
    // Tab DIKIRIM
    _tabsData.add(
      OrderTabsModel(
        header: Tab(
          icon: _tabsBadge[2] != '0'
              ? Badge(
                  label: Text(_tabsBadge[2]),
                  textColor: cWhite,
                  backgroundColor: cPrimary100,
                  child: Icon(
                    _tabController.index == 2
                        ? Icons.fire_truck
                        : Icons.fire_truck_outlined,
                  ),
                )
              : Icon(
                  _tabController.index == 2
                      ? Icons.fire_truck
                      : Icons.fire_truck_outlined,
                ),
        ),
        body: ListOrder(
          status: StatusOrder.dikirim.name,
          items: (items) => setState(() {
            _tabsBadge[2] = '${items.length}';
          }),
        ),
      ),
    );
    // Tab SELESAI
    _tabsData.add(
      OrderTabsModel(
        header: Tab(
          icon: Icon(
            _tabController.index == 3
                ? Icons.check_circle
                : Icons.check_circle_outline,
          ),
        ),
        body: ListOrder(
          status: StatusOrder.selesai.name,
          items: (items) => setState(() {
            _tabsBadge[3] = '${items.length}';
          }),
        ),
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
  List<OrderModel> _items = [];
  bool _isLoading = true;
  ContactModel? _userData;

  @override
  void initState() {
    _getUserData();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _onRefresh() async {
    setState(() {
      _isLoading = true;
    });
    _getUserData();
  }

  void _getUserData() async {
    final data = await getContactModel();
    setState(() {
      _userData = data;
    });
    _getList();
  }

  void _getList() async {
    await AppOrderApi().get(
      idContact: _userData?.idContact ?? '-1',
      statusOrder: widget.status?.toUpperCase() ?? 'ALL',
      onError: (e) {
        showSnackBar(context, e);
      },
      onCompleted: (data) {
        _items = data ?? [];
        if (widget.items != null) {
          widget.items!(_items);
        }
        setState(() {
          _isLoading = false;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator.adaptive(
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
}

// Card Order Widget
class CardOrder extends StatelessWidget {
  const CardOrder({super.key, required this.item});

  final OrderModel item;

  void _navigateToDetail(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (ctx) => OrderDetailScreen(idAppOrder: item.idAppOrder),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final totalItems = item.items.length;
    final totalQty = int.tryParse(item.totalQty) != null
        ? int.parse(item.totalQty)
        : item.items.length;
    final moreItems = totalQty - totalItems;

    return Card(
      color: cWhite,
      clipBehavior: Clip.antiAliasWithSaveLayer,
      elevation: 0,
      shadowColor: cDark600,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
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
                      MyDateFormat.formatDate(
                        item.createdAt,
                        outputFormat: 'dd MMMM yyyy, HH:mm',
                      ),
                      style: const TextStyle(color: cDark200),
                    ),
                  ],
                ),
                _generateStatusBadge(),
              ],
            ),
            Container(
              margin: const EdgeInsets.symmetric(vertical: 12),
              child: const Divider(height: 1, color: cDark500),
            ),
            ListView.separated(
              shrinkWrap: true,
              itemCount: totalItems,
              physics: const NeverScrollableScrollPhysics(),
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final product = item.items[index];
                return SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          color: cDark600,
                          width: 50,
                          height: 50,
                          child: Image.network(
                            key: Key(product.idProduct),
                            product.imgProduk.isNotEmpty
                                ? product.imgProduk
                                : 'https://google.com',
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return const Icon(
                                Icons.broken_image,
                                size: 25,
                                color: Colors.grey,
                              );
                            },
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            product.nameProduk,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Row(
                            children: [
                              Text(
                                '${CurrencyFormat().format(amount: double.parse(product.priceProduk))} (${product.qtyAppOrderDetail}x)',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: cPrimary100,
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
            moreItems > 0
                ? Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Text(
                      '+ $moreItems produk Lainnya',
                      textAlign: TextAlign.end,
                      style: TextStyle(color: cDark200),
                    ),
                  )
                : const SizedBox.shrink(),
            Container(
              margin: const EdgeInsets.symmetric(vertical: 12),
              child: const Divider(height: 1, color: cDark500),
            ),
            Row(
              // mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Total $totalItems produk'),
                      Row(
                        children: [
                          Text(
                            CurrencyFormat().format(
                              amount: double.parse(item.totalAppOrder),
                            ),
                            style: const TextStyle(
                              color: cPrimary100,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 8),
                          if (item.discountAppOrder.isNotEmpty)
                            Text(
                              CurrencyFormat().format(
                                amount: double.parse(item.subTotalAppOrder),
                              ),
                              style: TextStyle(
                                fontSize: 12,
                                decoration: TextDecoration.lineThrough,
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                InkWell(
                  onTap: () => _navigateToDetail(context),
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

  Container _generateStatusBadge() {
    final status = item.statusAppOrder.toLowerCase();
    List<Color> badgeColor = List.of({Colors.grey[400]!, Colors.grey[800]!});
    if (status == StatusOrder.dikirim.name) {
      badgeColor = List.of({Colors.blue[100]!, Colors.blue[800]!});
    } else if (status == StatusOrder.selesai.name) {
      badgeColor = List.of({Colors.green[100]!, Colors.green[800]!});
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: badgeColor[0].withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        item.statusAppOrder,
        style: TextStyle(
          color: badgeColor[1],
          fontWeight: FontWeight.bold,
          fontSize: 10,
        ),
      ),
    );
  }
}
