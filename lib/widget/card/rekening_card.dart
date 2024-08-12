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
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8), // Menentukan sudut melengkung
      ),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
        decoration: BoxDecoration(
          color: cWhite,
          border: Border.all(color: cDark500, width: 1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'PT. BCA (Bank Central Asia) TBK',
                    style: Theme.of(context).textTheme.titleSmall!.copyWith(
                          color: cDark100,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  Text(
                    '0918230981283',
                    style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                          color: cDark100,
                          fontWeight: FontWeight.normal,
                        ),
                  ),
                  Text(
                    'a.n Mochammad Rafli Ramadani',
                    style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                          color: cDark200,
                          fontWeight: FontWeight.normal,
                        ),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: () {},
              icon: const Icon(
                Icons.delete_forever_rounded,
                color: cDark200,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
