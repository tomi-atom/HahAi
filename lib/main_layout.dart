import 'package:hahai/screens/artikel_page.dart';
import 'package:hahai/screens/home_page.dart';
import 'package:hahai/screens/home_absen.dart';
import 'package:hahai/screens/info_page.dart';
import 'package:hahai/screens/notifikasi_page.dart';
import 'package:hahai/screens/page_absensi.dart';
import 'package:hahai/screens/profile_page.dart';
import 'package:hahai/screens/rambu_page.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hahai/screens/tool_page.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({Key? key}) : super(key: key);

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  //variable declaration
  int currentPage = 0;
  final PageController _page = PageController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _page,
        physics: NeverScrollableScrollPhysics(),
        onPageChanged: ((value) {
          setState(() {
            currentPage = value;
          });
        }),
        children: <Widget>[
          const HomePage(),
          ToolPage(),
          ArtikelPage(),
          ProfilePage(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentPage,
        onTap: (page) {
          setState(() {
            currentPage = page;
            _page.animateToPage(
              page,
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeInOut,
            );
          });
        },
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: FaIcon(FontAwesomeIcons.house),
            label: 'Home',
          ),

          BottomNavigationBarItem(
            icon: FaIcon(FontAwesomeIcons.arrowTrendUp),
            label: 'Trending',
          ),
          BottomNavigationBarItem(
            icon: FaIcon(FontAwesomeIcons.newspaper),
            label: 'Artikel',
          ),

          BottomNavigationBarItem(
            icon: FaIcon(FontAwesomeIcons.addressBook),
            label: 'About',
          ),
        ],
      ),
    );
  }
}
