import 'package:flutter/material.dart';
import 'package:topmortarseller/util/enum.dart';
import 'package:topmortarseller/util/colors/color.dart';
import 'package:topmortarseller/util/loading_item.dart';

class MainDrawerHeader extends StatelessWidget {
  const MainDrawerHeader({
    super.key,
    required this.title,
    required this.description,
  });

  final String? title;
  final String? description;

  @override
  Widget build(BuildContext context) {
    return DrawerHeader(
      // padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            cPrimary100,
            cPrimary200,
            cPrimary100,
            cPrimary200,
            cPrimary100,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Hero(
        tag: TagHero.mainDrawerHeader,
        child: SizedBox(
          width: double.infinity,
          child: Column(
            children: [
              // const Icon(
              //   Icons.storefront,
              //   size: 48,
              //   color: cWhite,
              // ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: cPrimary100,
                  borderRadius: BorderRadius.all(
                    Radius.circular(80),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: cPrimary200, // Warna bayangan dengan transparansi
                      spreadRadius: 1, // Jarak penyebaran bayangan
                      blurRadius: 2, // Jarak kabur bayangan
                      offset: Offset(
                          1, 1.5), // Posisi bayangan (horizontal, vertikal)
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.storefront,
                  color: cWhite,
                  size: 48,
                ),
              ),
              const SizedBox(height: 8),
              title == null
                  ? const LoadingItem()
                  : Text(
                      title!,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleMedium!.copyWith(
                            color: cWhite,
                          ),
                    ),
              description == null
                  ? const LoadingItem()
                  : Text(
                      description!,
                      softWrap: true,
                      overflow: TextOverflow.visible,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodySmall!.copyWith(
                            color: cPrimary600,
                          ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
