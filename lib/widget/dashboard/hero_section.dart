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
      height: 250,
      decoration: BoxDecoration(
        color: cPrimary200,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -50,
            bottom: 0,
            child: Opacity(
              opacity: 0.2,
              child: Hero(
                tag: TagHero.mainDrawerHeader,
                child: Icon(Icons.storefront, color: cWhite, size: 200),
              ),
            ),
          ),
          Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // const SizedBox.expand(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Top Mortar Seller',
                        style: Theme.of(
                          context,
                        ).textTheme.titleLarge!.copyWith(color: cWhite),
                      ),
                      Hero(
                        tag: TagHero.faviconAuth,
                        child: Semantics(
                          label: '${TagHero.faviconAuth}',
                          child: Image.asset(
                            'assets/favicon/favicon_circle.png',
                            width: 32,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Text(
                    "Halo,",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
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
                  Text(
                    "0 Poin",
                    style: TextStyle(
                      color: Colors.yellow,
                      fontWeight: FontWeight.normal,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Material(
                    color: Colors.white,
                    // elevation: 1,
                    borderRadius: BorderRadius.circular(100),
                    child: TextFormField(
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.search),
                        // contentPadding: EdgeInsets.only(left: 24),
                        hintText: "Cari produk sekarang",
                        // enabledBorder: InputBorder.none,
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white, width: 0),
                          borderRadius: BorderRadius.circular(100),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white, width: 0),
                          borderRadius: BorderRadius.circular(100),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
