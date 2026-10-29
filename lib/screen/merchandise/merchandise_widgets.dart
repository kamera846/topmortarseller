import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:topmortarseller/services/merchandise_points.dart';
import 'package:topmortarseller/util/colors/color.dart';

String formatPoints(int value) =>
    NumberFormat.decimalPattern('id_ID').format(value);

class MerchandiseImage extends StatelessWidget {
  const MerchandiseImage({super.key, required this.url});

  final String url;

  @override
  Widget build(BuildContext context) {
    const placeholder = Center(
      child: Icon(Icons.card_giftcard_rounded, size: 56, color: cDark300),
    );
    return AspectRatio(
      aspectRatio: 1.25,
      child: ColoredBox(
        color: Colors.white,
        child: url.isEmpty
            ? placeholder
            : Image.network(
                url,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => placeholder,
                loadingBuilder: (_, child, progress) =>
                    progress == null ? child : placeholder,
              ),
      ),
    );
  }
}

class MerchandiseBalanceCard extends StatelessWidget {
  const MerchandiseBalanceCard({
    super.key,
    required this.points,
    this.enabled = true,
  });

  final MerchandisePoints points;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [cPrimary100, cPrimary200]),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.stars_rounded, color: Colors.white),
              SizedBox(width: 8),
              Text('Poin Saya', style: TextStyle(color: Colors.white)),
            ],
          ),
          const SizedBox(height: 12),
          if (points.isLoading)
            const LinearProgressIndicator(
              color: Colors.white,
              backgroundColor: cPrimary300,
              semanticsLabel: 'Memperbarui poin',
            )
          else if (points.total == null) ...[
            const Text(
              'Saldo poin belum dapat dimuat.',
              style: TextStyle(color: Colors.white),
            ),
            TextButton.icon(
              onPressed: enabled ? points.refresh : null,
              style: TextButton.styleFrom(foregroundColor: Colors.white),
              icon: const Icon(Icons.refresh),
              label: const Text('Muat ulang poin'),
            ),
          ] else ...[
            Text(
              '${formatPoints(points.total!)} poin',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Tukarkan poin dengan merchandise pilihanmu.',
              style: TextStyle(color: Colors.white),
            ),
          ],
        ],
      ),
    );
  }
}
