import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:topmortarseller/util/colors/color.dart';

class StoreInfoModal extends StatelessWidget {
  const StoreInfoModal({
    super.key,
    required this.name,
    required this.address,
    required this.onConfirm,
    required this.onCancel,
  });

  final String name;
  final String address;
  final VoidCallback onConfirm;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    return CupertinoAlertDialog(
      title: const Text('Apa benar ini toko anda?'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton.outlined(
            onPressed: () {},
            icon: const Icon(Icons.storefront_outlined),
          ),
          Text(
            name,
            style: Theme.of(context)
                .textTheme
                .titleMedium!
                .copyWith(color: cDark100),
          ),
          Text(
            address,
            style: Theme.of(context)
                .textTheme
                .bodyMedium!
                .copyWith(color: cDark300),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: onCancel,
          child: const Text('Bukan'),
        ),
        TextButton(
          onPressed: onConfirm,
          child: const Text('Oke, Lanjut'),
        ),
      ],
    );
  }
}
