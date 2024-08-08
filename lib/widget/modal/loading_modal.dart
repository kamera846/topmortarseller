import 'package:flutter/cupertino.dart';
import 'package:topmortarseller/util/colors/color.dart';

class LoadingModal extends StatelessWidget {
  const LoadingModal({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CupertinoPopupSurface(
        isSurfacePainted: false,
        child: SizedBox(
          width: double.infinity,
          height: double.infinity,
          child: CupertinoActivityIndicator(
            color: cPrimary100,
            radius: 20.0,
          ),
        ),
      ),
    );
  }
}
