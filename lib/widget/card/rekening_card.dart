import 'package:flutter/material.dart';
import 'package:topmortarseller/util/colors/color.dart';

class RekeningCard extends StatefulWidget {
  const RekeningCard({
    super.key,
    required this.bankName,
    required this.rekening,
    required this.rekeningName,
    this.backgroundColor = cWhite,
    this.rightIcon = Icons.keyboard_arrow_right_rounded,
    this.rightIconColor = cDark200,
    this.action,
    this.withDeleteAction = false,
  });

  final String bankName;
  final String rekening;
  final String rekeningName;
  final Color backgroundColor;
  final IconData rightIcon;
  final Color rightIconColor;
  final Function()? action;
  final bool withDeleteAction;

  @override
  State<RekeningCard> createState() => _RekeningCardState();
}

class _RekeningCardState extends State<RekeningCard> {
  @override
  Widget build(BuildContext context) {
    Widget cardWidget = Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8), // Menentukan sudut melengkung
      ),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        decoration: BoxDecoration(
          color: widget.backgroundColor,
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
                    '${widget.bankName} • ${widget.rekening}',
                    overflow: TextOverflow.ellipsis,
                    softWrap: true,
                    style: Theme.of(context).textTheme.titleSmall!.copyWith(
                          color: cDark100,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  Text(
                    'a.n ${widget.rekeningName}',
                    overflow: TextOverflow.ellipsis,
                    softWrap: true,
                    style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                          color: cDark100,
                          fontWeight: FontWeight.normal,
                        ),
                  ),
                  // Text(
                  //   widget.rekening,
                  //   style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                  //         color: cDark100,
                  //         fontWeight: FontWeight.normal,
                  //       ),
                  // ),
                ],
              ),
            ),
            IconButton(
              onPressed: widget.action ?? () {},
              icon: Icon(
                widget.withDeleteAction == true
                    ? Icons.delete_forever_rounded
                    : widget.rightIcon,
                color: widget.rightIconColor,
              ),
            ),
          ],
        ),
      ),
    );
    return widget.action != null
        ? InkWell(
            onTap: widget.action,
            child: cardWidget,
          )
        : cardWidget;
  }
}
