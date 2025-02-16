import 'package:flutter/material.dart';
import 'package:topmortarseller/model/contact_model.dart';
import 'package:topmortarseller/util/colors/color.dart';
import 'package:topmortarseller/widget/drawer/main_drawer_header.dart';
import 'package:topmortarseller/widget/drawer/main_drawer_items.dart';

class MainDrawer extends StatefulWidget {
  const MainDrawer({
    super.key,
    this.userData,
  });

  final ContactModel? userData;

  @override
  State<MainDrawer> createState() => _MainDrawerState();
}

class _MainDrawerState extends State<MainDrawer> {
  ContactModel? _userData;
  String? title;
  String? description;

  @override
  void initState() {
    _getUserData();
    super.initState();
  }

  void _getUserData() async {
    // final data = widget.userData ?? await getContactModel();
    final data = await getContactModel();
    setState(() {
      _userData = data;

      if (data != null) {
        if (data.nama != null && data.nama != null && data.nama!.isNotEmpty) {
          title = data.nama!;
        }
        if (data.address != null &&
            data.address != null &&
            data.address!.isNotEmpty) {
          description = data.address!;
        } else if (data.nomorhp != null &&
            data.nomorhp != null &&
            data.nomorhp!.isNotEmpty) {
          description = data.nomorhp!;
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: cWhite,
      child: Column(
        children: [
          MainDrawerHeader(
            title: title,
            description: description,
          ),
          MainDrawerItems(userData: _userData)
        ],
      ),
    );
  }
}
