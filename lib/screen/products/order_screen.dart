import 'package:flutter/material.dart';
import 'package:topmortarseller/model/contact_model.dart';
import 'package:topmortarseller/util/colors/color.dart';
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
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
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
                itemCount: 5,
                itemBuilder: (ctx, idx) {
                  return const CardOrder();
                },
              ),
            ),
    );
  }
}

class CardOrder extends StatelessWidget {
  const CardOrder({super.key});

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
                const Row(
                  children: [
                    Icon(
                      Icons.calendar_month_rounded,
                      color: cDark200,
                    ),
                    SizedBox(width: 8),
                    Text(
                      '2025-02-08',
                      style: TextStyle(color: cDark200),
                    ),
                  ],
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green[100],
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'Selesai',
                    style: TextStyle(
                      color: Colors.green[800],
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
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
              itemCount: 2,
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) {
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
                          borderRadius: BorderRadius.circular(12),
                          image: const DecorationImage(
                            image: NetworkImage(
                              '',
                            ),
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Lorem ipsum sit dolor amet',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Row(
                            children: [
                              Text(
                                'Rp 45.000 (2x)',
                                style:
                                    TextStyle(fontSize: 12, color: cPrimary100),
                              ),
                              SizedBox(width: 8),
                              Text(
                                'Rp 50.000',
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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total 2 produk',
                    ),
                    Text(
                      'Rp 180.000',
                      style: TextStyle(
                          color: cPrimary100, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                InkWell(
                  onTap: () {},
                  child: Material(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.blue.withAlpha(200),
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
