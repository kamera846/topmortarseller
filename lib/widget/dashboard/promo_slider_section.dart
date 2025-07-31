import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:topmortarseller/util/colors/color.dart';

class PromoSliderSection extends StatelessWidget {
  const PromoSliderSection({super.key});

  @override
  Widget build(BuildContext context) {
    final List<String> promoItems = [
      'https://media.istockphoto.com/id/1214771295/vector/realistic-red-grand-opening-banner-hanging-on-a-grey-wall.jpg?s=612x612&w=0&k=20&c=Pii5QNuYcEdTGxtMz_tS00v6ZtuhrFofWAdI4Dq8r8g=',
      'https://img.freepik.com/free-photo/front-view-shop-word-red-table_23-2148281114.jpg?semt=ais_hybrid&w=740&q=80',
      'https://media.istockphoto.com/id/1412949747/vector/sale-sticker-with-50-percent-off-weekend-discount.jpg?s=612x612&w=0&k=20&c=xOJuBoLp04OHo4R-w_Ub_jfRIbgJ0N77rWl8SjIBfCI=',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 12, top: 12, right: 12),
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
                color: cWhite,
                elevation: 1,
                borderRadius: BorderRadius.circular(12),
                child: ClipRRect(
                  borderRadius: BorderRadiusGeometry.circular(12),
                  child: Image.network(
                    item,
                    errorBuilder: (context, error, stackTrace) => SizedBox(
                      width: double.infinity,
                      height: double.infinity,
                      child: Icon(Icons.error),
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
