import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:topmortarseller/util/colors/color.dart';

class PromoSliderSection extends StatelessWidget {
  const PromoSliderSection({super.key});

  @override
  Widget build(BuildContext context) {
    final List<String> promoItems = [
      'https://google.com',
      'https://google.com',
      'https://google.com',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 12, right: 12),
          child: Text(
            'Promo',
            style: Theme.of(context).textTheme.titleMedium!.copyWith(
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
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
              child: Material(
                color: Colors.white,
                elevation: 1,
                borderRadius: BorderRadius.circular(16),
                child: ClipRRect(
                  borderRadius: BorderRadiusGeometry.circular(16),
                  child: Image.network(
                    item,
                    errorBuilder: (context, error, stackTrace) => SizedBox(
                      width: double.infinity,
                      height: double.infinity,
                      child: Icon(Icons.error, color: Colors.grey),
                    ),
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
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
