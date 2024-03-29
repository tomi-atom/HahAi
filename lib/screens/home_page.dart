import 'dart:convert';
import 'package:hahai/screens/detail_artikel.dart';
import 'package:hahai/utils/config.dart';
import 'package:art_sweetalert/art_sweetalert.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:hahai/main.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/dio_provider.dart';
import 'artikel_details.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  DioProvider dioProvider = DioProvider(); // Initialize DioProvider here
  String url = DioProvider().url;
  Map<String, dynamic> background = {};
  List<dynamic> favList = [];
  List<dynamic> artikel = [];
  List<dynamic> tool = [];
  late TextEditingController _search;



  Future<void> getArtikel() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final data = await dioProvider.getArtikel();

    if (data != 'Error') {
      print('Cek Artikel $data');

      setState(() {
        // Decode JSON data
        artikel = json.decode(data);

        // Display only the first 3 articles
        artikel = artikel.length > 10 ? artikel.sublist(0, 10) : artikel;

        print('Cek Artikel $artikel');
      });
    }
  }



  Future<Map<String, dynamic>> getUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userDataString = prefs.getString('user_data');

    if (userDataString != null) {
      return jsonDecode(userDataString);
    } else {
      return {};
    }
  }

  @override
  void initState() {
    super.initState();
    dioProvider.initializeDio();
    getArtikel();
    WidgetsBinding.instance?.addPostFrameCallback((_) {
      // Fungsi ini akan dipanggil setelah widget selesai dibangun
      Navigator.of(context).restorablePushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => HomePage()) as RestorableRouteBuilder<Object?>,
            (route) => false,
      );
    });


  }
  Future<void> _onRefresh() async {
     await getArtikel();
    ArtSweetAlert.show(
      context: context,
      artDialogArgs: ArtDialogArgs(
        type: ArtSweetAlertType.success,
        title: "Refreshed",
        text: "Data berhasil diperbarui.",
        confirmButtonText: "OK",
      ),
    );
  }



  @override
  Widget build(BuildContext context) {
    Config().init(context);

    return Scaffold(

      body: Container(

          child: SafeArea(
            child: RefreshIndicator(
              onRefresh: _onRefresh,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[


                  Expanded(
                    flex: 4,
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color:Config.primaryColor,
                        image: DecorationImage(
                          image: AssetImage('assets/background.gif'), // Ganti dengan path gambar latar belakang yang sesuai
                          fit: BoxFit.cover,
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 15,
                          vertical: 15,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Config.spaceSmall,
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Expanded(
                                  child: TextField(
                                    style: TextStyle(color: Colors.white), // Mengatur warna teks menjadi putih
                                    decoration: InputDecoration(
                                      labelText: 'Cari..',
                                      labelStyle: TextStyle(color: Colors.white), // Mengatur warna label menjadi putih
                                      border: OutlineInputBorder(
                                        borderSide: BorderSide(color: Colors.white), // Mengatur warna border menjadi putih
                                      ),
                                    ),
                                    maxLines: 1, // Karena berada di dalam Row, lebih baik maxLines diatur ke 1
                                  ),
                                ),

                                SizedBox(width: 10), // Menambahkan sedikit ruang antara text field dan logo
                                Container(
                                  decoration: BoxDecoration(
                                    border: Border(
                                      bottom: BorderSide(
                                        width: 2.0,
                                      ),
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.white.withOpacity(0.5),
                                        spreadRadius: 5,
                                        blurRadius: 5,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                    shape: BoxShape.circle,
                                  ),
                                  child: Image.asset(
                                    'assets/logo.png',
                                    width: 50,
                                    height: 50,
                                  ),
                                ),
                              ],
                            ),
                            Config.spaceSmall,
                            Container(
                              decoration: BoxDecoration(
                                 color:Config.primaryColor.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(16.0),
                                boxShadow: [
                                  BoxShadow(
                                    color:Config.primaryColor.withOpacity(0.1),
                                    spreadRadius: 2,
                                    blurRadius: 2,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              padding: EdgeInsets.only(top: 8.0, left: 8.0, right: 8.0, bottom: 8.0),

                              child: Column(
                                children: [
                                  SizedBox(width: 8.0),
                                  Text(
                                    'Trending',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontFamily: 'NeoSans',
                                      fontSize: 16.0,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),

                                  CarouselSlider(
                                    options: CarouselOptions(
                                      height: 80.0,
                                      autoPlay: true,
                                      enlargeCenterPage: true,
                                      aspectRatio: 9 / 16,
                                      autoPlayCurve: Curves.fastOutSlowIn,
                                      enableInfiniteScroll: true,
                                      autoPlayAnimationDuration: Duration(milliseconds: 800),
                                      viewportFraction: 0.5,
                                    ),
                                    items: artikel.isEmpty
                                        ? [
                                      Builder(
                                        builder: (BuildContext context) {
                                          return Container(
                                            width: MediaQuery.of(context).size.width,
                                            margin: EdgeInsets.symmetric(horizontal: 5.0),
                                            decoration: BoxDecoration(
                                              color:Config.primaryColor,
                                              borderRadius: BorderRadius.circular(8.0),
                                            ),
                                            child: Center(
                                              child: Text(
                                                'Berita',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 16.0,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ]
                                        : artikel.map((article) {
                                      return Builder(
                                        builder: (BuildContext context) {
                                          return GestureDetector(
                                            onTap: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      DetailArtikel(artikelData: article),
                                                ),
                                              );
                                            },
                                            child: Container(
                                              width: MediaQuery.of(context).size.width,
                                              margin: EdgeInsets.symmetric(horizontal: 5.0),
                                              decoration: BoxDecoration(
                                                borderRadius: BorderRadius.circular(8.0),
                                                image: DecorationImage(
                                                  image: NetworkImage(
                                                      '${DioProvider().url}/${article['gambar']}'),
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                              child: Column(
                                                mainAxisAlignment: MainAxisAlignment.end,
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: <Widget>[
                                                  Container(
                                                    padding: EdgeInsets.symmetric(
                                                        horizontal: 10, vertical: 5),
                                                    decoration: BoxDecoration(
                                                      color: Colors.black.withOpacity(0.7),
                                                      borderRadius: BorderRadius.only(
                                                        bottomLeft: Radius.circular(8),
                                                        bottomRight: Radius.circular(8),
                                                      ),
                                                    ),
                                                    child: Text(
                                                      article['judul'],
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 10.0,
                                                        fontWeight: FontWeight.bold,
                                                      ),
                                                    ),
                                                  ),

                                                ],
                                              ),
                                            ),
                                          );
                                        },
                                      );
                                    }).toList(),
                                  ),
                                ],
                              ),
                            ),
                            Config.spaceSmall,

                            Container(
                              decoration: BoxDecoration(
                                 color:Config.primaryColor.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(16.0),
                                boxShadow: [
                                  BoxShadow(
                                    color:Config.primaryColor.withOpacity(0.1),
                                    spreadRadius: 2,
                                    blurRadius: 2,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              padding: EdgeInsets.only(top: 8.0, left: 8.0, right: 8.0, bottom: 8.0),

                              child: Column(
                                children: [
                                  SizedBox(width: 8.0),
                                  Text(
                                    'Berita',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontFamily: 'NeoSans',
                                      fontSize: 16.0,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),

                                  CarouselSlider(
                                    options: CarouselOptions(
                                      height: 80.0,
                                      autoPlay: true,
                                      enlargeCenterPage: true,
                                      aspectRatio: 9 / 16,
                                      autoPlayCurve: Curves.fastOutSlowIn,
                                      enableInfiniteScroll: true,
                                      autoPlayAnimationDuration: Duration(milliseconds: 800),
                                      viewportFraction: 0.5,
                                    ),
                                    items: artikel.isEmpty
                                        ? [
                                      Builder(
                                        builder: (BuildContext context) {
                                          return Container(
                                            width: MediaQuery.of(context).size.width,
                                            margin: EdgeInsets.symmetric(horizontal: 5.0),
                                            decoration: BoxDecoration(
                                              color:Config.primaryColor,
                                              borderRadius: BorderRadius.circular(8.0),
                                            ),
                                            child: Center(
                                              child: Text(
                                                'Berita',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 14.0,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ]
                                        : artikel.map((article) {
                                      return Builder(
                                        builder: (BuildContext context) {
                                          return GestureDetector(
                                            onTap: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      DetailArtikel(artikelData: article),
                                                ),
                                              );
                                            },
                                            child: Container(
                                              width: MediaQuery.of(context).size.width,
                                              margin: EdgeInsets.symmetric(horizontal: 5.0),
                                              decoration: BoxDecoration(
                                                borderRadius: BorderRadius.circular(8.0),
                                                image: DecorationImage(
                                                  image: NetworkImage(
                                                      '${DioProvider().url}/${article['gambar']}'),
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                              child: Column(
                                                mainAxisAlignment: MainAxisAlignment.end,
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: <Widget>[
                                                  Container(
                                                    padding: EdgeInsets.symmetric(
                                                        horizontal: 10, vertical: 5),
                                                    decoration: BoxDecoration(
                                                      color: Colors.black.withOpacity(0.7),
                                                      borderRadius: BorderRadius.only(
                                                        bottomLeft: Radius.circular(8),
                                                        bottomRight: Radius.circular(8),
                                                      ),
                                                    ),
                                                    child: Text(
                                                      article['judul'],
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 10.0,
                                                        fontWeight: FontWeight.bold,
                                                      ),
                                                    ),
                                                  ),

                                                ],
                                              ),
                                            ),
                                          );
                                        },
                                      );
                                    }).toList(),
                                  ),
                                ],
                              ),
                            ),
                            Config.spaceSmall,
                            Expanded(
                              child: artikel.isNotEmpty
                                  ? ListView.builder(
                                shrinkWrap: true,
                                physics:AlwaysScrollableScrollPhysics(),
                                itemCount: artikel.length,
                                itemBuilder: (context, index) {
                                  var article = artikel[index];
                                  var tanggal =
                                  DateTime.parse(article['published_at']);
                                  var formattedDate =
                                  DateFormat.yMMMMd().format(tanggal);

                                  return Container(
                                    margin: EdgeInsets.symmetric(vertical: 8.0),
                                    decoration: BoxDecoration(
                                      color:Config.primaryColor.withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(16.0),
                                      boxShadow: [
                                        BoxShadow(
                                          color:Config.primaryColor.withOpacity(0.1),
                                          spreadRadius: 2,
                                          blurRadius: 2,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: ListTile(
                                      leading: ClipRRect(
                                        borderRadius: BorderRadius.circular(8.0),
                                        child: Image.network(
                                          '$url/${article['gambar']}',
                                          width: 50,
                                          height: 50,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                      title: Text(
                                        article['judul'],
                                        style: TextStyle(color: Colors.white), // Mengatur warna teks menjadi putih
                                      ),
                                      subtitle: Text(
                                        formattedDate,
                                        style: TextStyle(color: Colors.white), // Mengatur warna teks menjadi putih
                                      ),

                                      onTap: () {
                                        // Navigate to the detail page
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => DetailArtikelPage(
                                              artikelData: article,
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  );
                                },
                              )
                                  : Center(child: Text(
                                'Data Tidak ditemukan',
                                style: TextStyle(color: Colors.white), // Mengatur warna teks menjadi putih
                              ),
                              ),

                            ),

                          ],
                        ),
                      ),

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
