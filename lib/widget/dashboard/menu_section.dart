import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:topmortarseller/screen/products/catalog_screen.dart';
import 'package:topmortarseller/screen/products/invoice_screen.dart';
import 'package:topmortarseller/screen/products/order_screen.dart';
import 'package:topmortarseller/util/colors/color.dart';
import 'package:topmortarseller/widget/snackbar/show_snackbar.dart';

class MenuSection extends StatelessWidget {
  final void Function() onResumed;
  const MenuSection({super.key, required this.onResumed});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> menuItems = [
      {
        'icon': Icons.shopping_bag,
        'title': 'Produk',
        'route': (context) => const CatalogScreen(),
      },
      {
        'icon': CupertinoIcons.cube_box_fill,
        'title': 'Pesanan',
        'route': (context) => const OrderScreen(),
      },
      {
        'icon': Icons.receipt_long,
        'title': 'Invoice',
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
            return InkWell(
              onTap: () {
                final Widget Function(BuildContext)? route = item['route'];
                if (route != null) {
                  Navigator.of(context)
                      .push(MaterialPageRoute(builder: route))
                      .then((value) => onResumed());
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
                      Icon(
                        item['icon'] as IconData,
                        size: 40,
                        color: cPrimary100,
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
