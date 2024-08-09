import 'package:flutter/material.dart';
import 'package:topmortarseller/model/contact_model.dart';
import 'package:topmortarseller/util/colors/color.dart';
import 'package:topmortarseller/widget/drawer/main_drawer_header.dart';
import 'package:topmortarseller/widget/drawer/main_drawer_items.dart';

class MainDrawer extends StatelessWidget {
  const MainDrawer({super.key, this.userData});

  final ContactModel? userData;

  @override
  Widget build(BuildContext context) {
    var title = '-';
    var description = '-';

    if (userData != null) {
      if (userData!.nama != null &&
          userData!.nama != null &&
          userData!.nama!.isNotEmpty) {
        title = userData!.nama!;
      }
      if (userData!.address != null &&
          userData!.address != null &&
          userData!.address!.isNotEmpty) {
        description = userData!.address!;
      } else if (userData!.nomorhp != null &&
          userData!.nomorhp != null &&
          userData!.nomorhp!.isNotEmpty) {
        description = userData!.nomorhp!;
      }
    }

    return Drawer(
      backgroundColor: cWhite,
      child: Column(
        children: [
          MainDrawerHeader(
            title: title,
            description: description,
          ),
          const MainDrawerItems()
        ],
      ),
    );
  }
}
