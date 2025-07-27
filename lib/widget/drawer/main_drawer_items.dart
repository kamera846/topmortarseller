import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:topmortarseller/model/contact_model.dart';
import 'package:topmortarseller/screen/auth_screen.dart';
import 'package:topmortarseller/screen/products/catalog_screen.dart';
import 'package:topmortarseller/screen/products/invoice_screen.dart';
import 'package:topmortarseller/screen/products/order_screen.dart';
import 'package:topmortarseller/screen/profile/detail_profile_screen.dart';
import 'package:topmortarseller/util/auth_settings.dart';
import 'package:topmortarseller/util/colors/color.dart';
import 'package:topmortarseller/widget/modal/info_modal.dart';

class MainDrawerItems extends StatelessWidget {
  const MainDrawerItems({super.key, this.userData});

  final ContactModel? userData;

  void _showConfirmlogout(BuildContext context) {
    showCupertinoDialog(
      context: context,
      builder: (BuildContext context) {
        return MInfoModal(
          contentName: 'Keluar dari akun?',
          contentDescription:
              'Anda diharuskan login kembali ketika mengakses aplikasi jika keluar dari akun.',
          contentIcon: Icons.warning_rounded,
          contentIconColor: cPrimary100,
          cancelText: 'Batal',
          onCancel: () {
            Navigator.of(context).pop();
          },
          onConfirm: () async {
            await removeLoginState();
            await removeContactModel();
            if (context.mounted) {
              Navigator.of(context).pop();
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (ctx) => const AuthScreen()),
              );
            }
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // User Profil
        DrawerItem(
          title: 'Profil Saya',
          description: 'Atur bank anda disini',
          icon: const Icon(
            CupertinoIcons.person_alt_circle,
            size: 26,
            color: cDark100,
          ),
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (ctx) => DetailProfileScreen(userData: userData),
              ),
            );
          },
        ),
        // Katalog Product
        DrawerItem(
          title: 'Katalog Produk',
          description: 'Dapatkan produk terbaik kami',
          icon: const Icon(Icons.trolley, size: 26, color: cDark100),
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (ctx) => CatalogScreen(userData: userData),
              ),
            );
          },
        ),
        // User Order
        DrawerItem(
          title: 'Pesananan Saya',
          description: 'Pantau status pesanan anda',
          icon: const Icon(
            CupertinoIcons.square_favorites_fill,
            size: 26,
            color: cDark100,
          ),
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (ctx) => OrderScreen(userData: userData),
              ),
            );
          },
        ),
        // User Invoices
        DrawerItem(
          title: 'Invoice Saya',
          description: 'Jaga reputasi dengan pembayaran tepat waktu',
          icon: const Icon(Icons.receipt_long, size: 26, color: cDark100),
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (ctx) => InvoiceScreen(userData: userData),
              ),
            );
          },
        ),
        // User Logout
        DrawerItem(
          title: 'Logout',
          description: 'Anda akan keluar dari akun saat ini',
          icon: const Icon(CupertinoIcons.power, size: 26, color: cDark100),
          onTap: () => _showConfirmlogout(context),
        ),
      ],
    );
  }
}

class DrawerItem extends StatelessWidget {
  const DrawerItem({
    super.key,
    required this.onTap,
    required this.title,
    required this.description,
    required this.icon,
  });

  final Function() onTap;
  final String title;
  final String description;
  final Icon icon;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          leading: icon,
          title: Text(
            title,
            style: Theme.of(context).textTheme.titleSmall!.copyWith(
              color: cDark100,
              fontWeight: FontWeight.bold,
            ),
          ),
          subtitle: Text(
            description,
            style: Theme.of(
              context,
            ).textTheme.bodySmall!.copyWith(color: cDark200),
          ),
          onTap: onTap,
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 32),
          child: Divider(height: 1, color: cDark500),
        ),
      ],
    );
  }
}
