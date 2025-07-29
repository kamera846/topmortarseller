import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:topmortarseller/util/colors/color.dart';

class PromoSliderSection extends StatelessWidget {
  const PromoSliderSection({super.key});

  @override
  Widget build(BuildContext context) {
    final List<String> promoItems = [
      'Ayo! Order melalui aplikasi dan dapatkan potongan harga.',
      'Belanja lebih hemat bonus koin aplikasi.',
      'Kumpulkan koin aplikasi, dan tukarkan dengan produk unggulan kami.',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: Text(
            'Promo',
            style: Theme.of(context).textTheme.titleSmall!.copyWith(
              color: cDark100,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        CarouselSlider.builder(
          options: CarouselOptions(aspectRatio: 3 / 1.2, autoPlay: true),
          itemCount: promoItems.length,
          itemBuilder: (context, index, realIndex) {
            final item = promoItems[index];
            return Padding(
              padding: const EdgeInsets.all(6),
              child: Material(
                color: cPrimary200,
                borderRadius: BorderRadius.circular(12),
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    item,
                    style: TextStyle(
                      color: cWhite,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
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
