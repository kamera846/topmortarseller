import 'package:flutter/material.dart';
import 'package:topmortarseller/model/promo_banner_model.dart';

class DetailPromoScreen extends StatelessWidget {
  final PromoBannerModel promo;
  const DetailPromoScreen({super.key, required this.promo});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Colors.white,
      child: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AspectRatio(
                aspectRatio: 2.5 / 1,
                child: Image.network(
                  promo.imgPromoTopseller ?? 'https://google.com',
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
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(promo.detailPromoTopseller ?? ''),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
