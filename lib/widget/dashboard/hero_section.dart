import 'package:flutter/material.dart';
import 'package:topmortarseller/model/contact_model.dart';
import 'package:topmortarseller/util/colors/color.dart';
import 'package:topmortarseller/util/enum.dart';

class HeroSection extends StatefulWidget {
  final ContactModel? userData;
  const HeroSection({super.key, this.userData});

  @override
  State<HeroSection> createState() => _HeroSectionState();
}

class _HeroSectionState extends State<HeroSection> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 220,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Top Mortar Seller',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleLarge!.copyWith(
                  color: cWhite,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                "0 Poin",
                style: TextStyle(
                  color: Colors.amber,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            ],
          ),
          const Spacer(),
          Text(
            "Halo,",
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          Text(
            widget.userData?.nama ?? '-',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.normal,
              fontSize: 20,
            ),
          ),
          const SizedBox(height: 12),
          Material(
            color: Colors.white,
            borderRadius: BorderRadius.circular(100),
            child: InkWell(
              onTap: () {},
              borderRadius: BorderRadius.circular(100),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(Icons.search),
                    const SizedBox(width: 12),
                    Text("Cari produk sekarang"),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
