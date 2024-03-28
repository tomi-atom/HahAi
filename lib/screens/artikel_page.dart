import 'dart:convert';

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

  String url = DioProvider().url;

  Map<String, dynamic> user = {};

  List<dynamic> artikel = [];

  //get artikel details
  Future<void> getLaporan() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';
    final rambu = await DioProvider().getArtikel();
    if (rambu != 'Error') {
      setState(() {
        artikel = json.decode(rambu);
        print(artikel);
      });
    }
  }
  @override
  void initState() {
    getLaporan();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    Config().init(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Berita & Pengumuman'),
        automaticallyImplyLeading: false,

      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 15,
          vertical: 15,
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[

              Expanded(
                child: artikel.isNotEmpty
                    ? ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
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
                        gradient: LinearGradient(
                          colors: [
                            Colors.white.withOpacity(0.8),
                          Colors.lightBlueAccent.withOpacity(0.45),
                          ],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
                            spreadRadius: 2,
                            blurRadius: 4,
                            offset: Offset(0, 3),
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
                        title: Text(article['judul']),
                        subtitle: Text(formattedDate),
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
                    : Center(child: Text('Data Tidak ditemukan')),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
