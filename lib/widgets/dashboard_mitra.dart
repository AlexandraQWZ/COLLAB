import 'package:flutter/material.dart';
// import 'package:permission_handler/permission_handler.dart';
import '../screen/beranda.dart';
import '../screen/riwayat.dart';
import '../screen/profil.dart';
import 'package:localization/localization.dart';

class DashboardMitra extends StatefulWidget {
  const DashboardMitra({super.key});

  @override
  State<DashboardMitra> createState() => _DashboardMitraState();
}

class _DashboardMitraState extends State<DashboardMitra> {
  int _selectedIndex = 0;
  List<Widget> _pages = [];

  // void photo() async {
  //   bool status = await Permission.storage.status.isGranted;
  //   if (await Permission.storage.status.isGranted) {
  //     // ignore: avoid_print
  //     print(status);
  //     return;
  //   } else {
  //     var status = await Permission.storage.request();
  //     if (status == PermissionStatus.granted) {
  //       return;
  //     } else if (status == PermissionStatus.permanentlyDenied) {
  //       openAppSettings();
  //     }
  //   }
  // }

  @override
  void initState() {
    super.initState();
    _pages = [
      const Beranda(),
      const Riwayat(),
      const Profil(),
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(
              Icons.home,
              color: _selectedIndex == 0 ? Colors.blue : Colors.black,
            ),
            label: 'beranda'.i18n(),
          ),
          // BottomNavigationBarItem(
          //   icon: Icon(
          //     Icons.wallet_travel,
          //     color: _selectedIndex == 1 ? Colors.blue : Colors.black,
          //   ),
          //   label: 'Keuangan',
          // ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.receipt_long,
              color: _selectedIndex == 1 ? Colors.blue : Colors.black,
            ),
            label: 'riwayat'.i18n(),
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.person,
              color: _selectedIndex == 2 ? Colors.blue : Colors.black,
            ),
            label: 'profil'.i18n(),
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.black,
        onTap: _onItemTapped,
      ),
    );
  }
}
