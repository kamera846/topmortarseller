import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:topmortarseller/model/promo_banner_model.dart';
import 'package:topmortarseller/services/promo_banner_api.dart';
import 'package:topmortarseller/util/colors/color.dart';

class PromoSliderSection extends StatefulWidget {
  const PromoSliderSection({super.key});

  @override
  State<PromoSliderSection> createState() => _PromoSliderSectionState();
}

class _PromoSliderSectionState extends State<PromoSliderSection> {
  bool isLoading = true;
  List<PromoBannerModel> listPromo = [];

  @override
  void initState() {
    super.initState();
    _getList();
  }

  void onRefresh() {
    setState(() {
      isLoading = true;
      listPromo = [];
    });
    _getList();
  }

  Future<void> _getList() async {
    await PromoBannerApi().get(
      onCompleted: (data) {
        setState(() {
          listPromo = data ?? [];
          isLoading = false;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
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
          options: CarouselOptions(aspectRatio: 2.5 / 1, autoPlay: true),
          itemCount: listPromo.length,
          itemBuilder: (context, index, realIndex) {
            final item = listPromo[index];
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
              child: Material(
                color: Colors.white,
                elevation: 1,
                borderRadius: BorderRadius.circular(16),
                child: ClipRRect(
                  borderRadius: BorderRadiusGeometry.circular(16),
                  child: Image.network(
                    item.imgPromoTopseller ?? 'https://google.com',
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
