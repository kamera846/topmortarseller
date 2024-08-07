import 'package:flutter/material.dart';
import 'package:topmortarseller/util/colors/color.dart';

class RekeningCard extends StatefulWidget {
  const RekeningCard({super.key});

  @override
  State<RekeningCard> createState() => _RekeningCardState();
}

class _RekeningCardState extends State<RekeningCard> {
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 20),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8), // Menentukan sudut melengkung
      ),
      child: Container(
        width: double.maxFinite,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: cDark600,
          border: Border.all(color: cDark500, width: 1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'BCA',
                    style: Theme.of(context)
                        .textTheme
                        .titleSmall!
                        .copyWith(color: cDark100, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '0918230981283',
                    style: Theme.of(context).textTheme.titleMedium!.copyWith(
                        color: cDark100, fontWeight: FontWeight.normal),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            TextButton(
              onPressed: () {},
              child: Text(
                'Edit',
                style: Theme.of(context)
                    .textTheme
                    .titleSmall!
                    .copyWith(color: cDark100, fontWeight: FontWeight.normal),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
