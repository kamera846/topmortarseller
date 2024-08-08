import 'package:flutter/material.dart';
import 'package:topmortarseller/util/colors/color.dart';
import 'package:topmortarseller/widget/drawer/main_drawer_header.dart';
import 'package:topmortarseller/widget/drawer/main_drawer_items.dart';

class MainDrawer extends StatelessWidget {
  const MainDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return const Drawer(
      backgroundColor: cWhite,
      child: Column(
        children: [MainDrawerHeader(), MainDrawerItems()],
      ),
    );
  }
}
