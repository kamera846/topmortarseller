import 'package:flutter/material.dart';
import 'package:topmortarseller/util/enum.dart';
import 'package:topmortarseller/util/colors/color.dart';

class MainDrawerHeader extends StatelessWidget {
  const MainDrawerHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return DrawerHeader(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            cPrimary100,
            cPrimary100.withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Hero(
        tag: TagHero.mainDrawerHeader,
        child: Row(
          children: [
            const Icon(
              Icons.storefront,
              size: 48,
              color: cWhite,
            ),
            const SizedBox(width: 18),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Toko Barokah Jaya',
                    style: Theme.of(context).textTheme.titleMedium!.copyWith(
                          color: cWhite,
                        ),
                  ),
                  Text(
                    'Jl Anggrek 3 asrikaton kec. pakis kab. malang',
                    softWrap: true,
                    overflow: TextOverflow.visible,
                    style: Theme.of(context).textTheme.bodySmall!.copyWith(
                          color: cPrimary600,
                        ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
