import 'package:flutter/material.dart';
import 'package:topmortarseller/util/colors/color.dart';

class LiveChatCard extends StatelessWidget {
  const LiveChatCard({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Semantics(
      button: true,
      label: 'Chat CS. Butuh bantuan seputar pesanan, produk, atau pembayaran?',
      onTap: onTap,
      excludeSemantics: true,
      child: Material(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(color: Color(0xFFE9D8D4)),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF9E9E7),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.support_agent_rounded,
                    color: cPrimary100,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Butuh bantuan?',
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: cDark100,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Tanyakan pesanan, produk, atau pembayaran kepada tim CS.',
                        style: textTheme.bodyMedium?.copyWith(
                          color: cDark200,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              'Chat CS',
                              style: textTheme.labelLarge?.copyWith(
                                color: cPrimary100,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(
                            Icons.arrow_forward_rounded,
                            color: cPrimary100,
                            size: 18,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
