import 'dart:convert';

import 'package:art_sweetalert/art_sweetalert.dart';
import 'package:hahai/screens/artikel_details.dart';
import 'package:hahai/utils/config.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../providers/dio_provider.dart';

class ArtikelPage extends StatefulWidget {
  const ArtikelPage({Key? key}) : super(key: key);

  @override
  State<ArtikelPage> createState() => _ArtikelPageState();
}

//enum for rambu kondisi
enum FilterRambu { Baik, Rusak }
class _ArtikelPageState extends State<ArtikelPage> {

  DioProvider dioProvider = DioProvider();
  String url = DioProvider().url;
  Map<String, dynamic> user = {};

  List<dynamic> artikel = [];


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
  @override
  void initState() {
    getArtikel();
    super.initState();
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
      appBar: AppBar(
        title: Text('Artikel'),
        automaticallyImplyLeading: false,

      ),
      body: Container(

        child: SafeArea(
          child: RefreshIndicator(
            onRefresh: _onRefresh,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[


                Expanded(

                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15.0),
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
