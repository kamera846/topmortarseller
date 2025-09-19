import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:topmortarseller/screen/products/catalog_screen.dart';
import 'package:topmortarseller/screen/products/invoice_screen.dart';
import 'package:topmortarseller/screen/products/order_screen.dart';
import 'package:topmortarseller/util/colors/color.dart';
import 'package:topmortarseller/util/enum.dart';
import 'package:topmortarseller/widget/snackbar/show_snackbar.dart';

class MenuSection extends StatelessWidget {
  final Map<String, int> badgeCounters;
  final void Function() onResumed;
  const MenuSection({
    super.key,
    this.badgeCounters = const {},
    required this.onResumed,
  });

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> menuItems = [
      {
        'icon': Icons.shopping_bag,
        'title': 'Produk',
        'badge': badgeCounters['cart'] ?? 0,
        'route': (context) => const CatalogScreen(),
      },
      {
        'icon': CupertinoIcons.cube_box_fill,
        'title': 'Pesanan',
        'badge': badgeCounters['order'] ?? 0,
        'route': (context) => const OrderScreen(),
      },
      {
        'icon': Icons.receipt_long,
        'title': 'Pembayaran',
        'badge': badgeCounters['invoice'] ?? 0,
        'route': (context) => const InvoiceScreen(),
      },
      {'icon': Icons.local_offer, 'title': 'Voucher', 'route': null},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Menu',
          style: Theme.of(context).textTheme.titleMedium!.copyWith(
            color: cDark100,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.zero,
          itemCount: menuItems.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemBuilder: (context, index) {
            final item = menuItems[index];
            final badge = item['badge'] is int ? item['badge'] as int : 0;
            return InkWell(
              onTap: () {
                final Widget Function(BuildContext)? route = item['route'];
                if (route != null) {
                  Navigator.of(
                    context,
                  ).push(MaterialPageRoute(builder: route)).then((value) {
                    if (value != null &&
                        value is PopValue &&
                        value == PopValue.isCheckouted) {
                      if (!context.mounted) return;
                      Navigator.of(context)
                          .push(
                            MaterialPageRoute(
                              builder: (context) => const OrderScreen(),
                            ),
                          )
                          .then((value) => onResumed());
                    } else {
                      onResumed();
                    }
                  });
                } else {
                  showSnackBar(context, 'Coming soon..');
                }
              },
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.all(0),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Badge(
                        label: Text(badge < 100 ? "$badge" : "99+"),
                        isLabelVisible: badge != 0,
                        backgroundColor: Colors.orange,
                        textStyle: TextStyle(fontWeight: FontWeight.bold),
                        padding: EdgeInsets.all(2),
                        child: Icon(
                          item['icon'] as IconData,
                          size: 40,
                          color: cPrimary100,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        item['title'] as String,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
