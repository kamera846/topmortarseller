import 'dart:async';

import 'package:flutter/material.dart';
import 'package:topmortarseller/model/contact_model.dart';
import 'package:topmortarseller/model/invoice_model.dart';
import 'package:topmortarseller/model/order_tabs_model.dart';
import 'package:topmortarseller/screen/products/invoice_detail_screen.dart';
import 'package:topmortarseller/services/invoice_api.dart';
import 'package:topmortarseller/util/colors/color.dart';
import 'package:topmortarseller/util/currency_format.dart';
import 'package:topmortarseller/util/date_format.dart';
import 'package:topmortarseller/util/enum.dart';
import 'package:topmortarseller/widget/snackbar/show_snackbar.dart';

class InvoiceScreen extends StatefulWidget {
  const InvoiceScreen({super.key, this.userData});

  final ContactModel? userData;

  @override
  State<InvoiceScreen> createState() => _InvoiceScreenState();
}

class _InvoiceScreenState extends State<InvoiceScreen>
    with TickerProviderStateMixin {
  late final TabController _tabController;
  final List<String> _tabsBadge = ['0', '0', '0'];
  final List<String> _tabsTitle = [
    'Pembayaran Saya',
    'Pembayaran Belum Lunas',
    'Pembayaran Lunas',
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
        physics: const NeverScrollableScrollPhysics(),
        children: _tabsData.map((item) {
          return item.body;
        }).toList(),
      ),
    );
  }

  @override
  void initState() {
    _tabController = TabController(length: 3, vsync: this);
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
        body: ListInvoice(
          items: (items) {
            setState(() {
              _tabsBadge[0] = items.length.toString();
              _tabsBadge[1] = items
                  .where(
                    (item) =>
                        item.statusInvoice.toLowerCase() ==
                        StatusOrder.waiting.name,
                  )
                  .length
                  .toString();
              _tabsBadge[2] = items
                  .where(
                    (item) =>
                        item.statusInvoice.toLowerCase() ==
                        StatusOrder.paid.name,
                  )
                  .length
                  .toString();
            });
            getTabsData();
          },
        ),
      ),
    );
    // Tab BELUM LUNAS
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
                        ? Icons.receipt_long
                        : Icons.receipt_long_outlined,
                  ),
                )
              : Icon(
                  _tabController.index == 1
                      ? Icons.receipt_long
                      : Icons.receipt_long_outlined,
                ),
        ),
        body: ListInvoice(
          status: StatusOrder.waiting.name,
          items: (items) => setState(() {
            _tabsBadge[1] = '${items.length}';
          }),
        ),
      ),
    );
    // Tab LUNAS
    _tabsData.add(
      OrderTabsModel(
        header: Tab(
          icon: Icon(
            _tabController.index == 2
                ? Icons.check_circle
                : Icons.check_circle_outline,
          ),
        ),
        body: ListInvoice(
          status: StatusOrder.paid.name,
          items: (items) => setState(() {
            _tabsBadge[2] = '${items.length}';
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
class ListInvoice extends StatefulWidget {
  const ListInvoice({super.key, this.status, this.items});

  final String? status;
  final Function(List<InvoiceModel> items)? items;

  @override
  State<ListInvoice> createState() => _ListInvoiceState();
}

class _ListInvoiceState extends State<ListInvoice> {
  List<InvoiceModel> _items = [];
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
    await InvoiceApi().get(
      idContact: _userData?.idContact ?? '-1',
      statusInvoice: widget.status?.toUpperCase() ?? 'ALL',
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
          ? Center(child: CircularProgressIndicator.adaptive())
          : Padding(
              padding: _items.isEmpty
                  ? const EdgeInsets.all(12)
                  : const EdgeInsets.symmetric(horizontal: 12),
              child: _items.isEmpty
                  ? const Text('Belum ada invoice', textAlign: TextAlign.center)
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
                          child: CardInvoice(
                            item: orderItem,
                            onRefresh: () => _onRefresh(),
                          ),
                        );
                      },
                    ),
            ),
    );
  }
}

// Card Order Widget
class CardInvoice extends StatelessWidget {
  const CardInvoice({super.key, required this.item, required this.onRefresh});

  final InvoiceModel item;
  final void Function() onRefresh;

  void _navigateToDetail(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (ctx) => InvoiceDetailScreen(idInvoice: item.idInvoice),
      ),
    ).then((value) {
      if (value is PopValue && value == PopValue.isPaid) {
        onRefresh();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    double totalInvoice = 0.0;
    if (double.tryParse(item.totalInvoice) != null) {
      totalInvoice = double.parse(item.totalInvoice);
    }
    double subTotalInvoice = 0.0;
    if (double.tryParse(item.subTotalInvoice) != null) {
      subTotalInvoice = double.parse(item.subTotalInvoice);
    }
    final totalItems = item.item.length;
    final totalQty = int.tryParse(item.totalQty) != null
        ? int.parse(item.totalQty)
        : item.item.length;
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
                        item.dateInvoice,
                        outputFormat: 'dd MMMM yyyy',
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
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Text('Invoice #${item.noInvoie}'),
            ),
            ListView.separated(
              shrinkWrap: true,
              itemCount: totalItems,
              physics: const NeverScrollableScrollPhysics(),
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final product = item.item[index];
                double priceProduct = 0.0;
                if (double.tryParse(product.price) != null) {
                  priceProduct = double.parse(product.price);
                }
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
                            product.imageProduk.isNotEmpty
                                ? product.imageProduk
                                : 'https://google.com',
                            key: Key(product.idProduct),
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
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            product.namaProduk,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Row(
                            children: [
                              Text(
                                '${CurrencyFormat().format(amount: priceProduct)} (${product.qtyProduk}x)',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: cPrimary100,
                                ),
                              ),
                              product.isBonus == '1'
                                  ? const Text(
                                      " Free",
                                      style: TextStyle(fontSize: 12),
                                    )
                                  : const SizedBox.shrink(),
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
                      Text('Total $totalQty produk'),
                      Row(
                        children: [
                          Text(
                            // _countPrice(item.items),
                            CurrencyFormat().format(amount: totalInvoice),
                            style: const TextStyle(
                              color: cPrimary100,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 8),
                          if (item.discountAppInvoice.isNotEmpty &&
                              item.discountAppInvoice != '0')
                            Text(
                              CurrencyFormat().format(amount: subTotalInvoice),
                              style: TextStyle(
                                fontSize: 12,
                                decoration: TextDecoration.lineThrough,
                                decorationThickness: 2,
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
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: cPrimary100.withAlpha(200),
                        width: 1,
                      ),
                    ),
                    child: const Text(
                      'Lihat Detail',
                      style: TextStyle(
                        color: cPrimary100,
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
    final status = item.statusInvoice.toLowerCase();
    List<Color> badgeColor = List.of({
      Colors.grey.shade400,
      Colors.grey.shade800,
    });
    if (status == StatusOrder.waiting.name) {
      badgeColor = List.of({Colors.orange.shade100, Colors.orange.shade800});
    } else if (status == StatusOrder.paid.name) {
      badgeColor = List.of({Colors.green.shade100, Colors.green.shade800});
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: badgeColor[0].withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        item.statusInvoice == StatusOrder.paid.name ? 'LUNAS' : 'BELUM LUNAS',
        style: TextStyle(
          color: badgeColor[1],
          fontWeight: FontWeight.bold,
          fontSize: 10,
        ),
      ),
    );
  }
}
