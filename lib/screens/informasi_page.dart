import 'package:hahai/utils/config.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:html_unescape/html_unescape.dart';
import '../providers/dio_provider.dart';

class InformasiPage extends StatefulWidget {
  const InformasiPage({Key? key}) : super(key: key);

  @override
  State<InformasiPage> createState() => _InformasiPageState();
}

//enum for rambu kondisi
class _InformasiPageState extends State<InformasiPage> {

  String url = DioProvider().url;
  Map<String, dynamic> about = {};
  Map<String, dynamic> profile = {};
  List<dynamic> artikel = [];
  String _removeHtmlTags(String htmlString) {
    final HtmlUnescape htmlUnescape = HtmlUnescape();
    return htmlUnescape.convert(htmlString.replaceAll(RegExp(r'<[^>]*>'), ''));
  }

  // Fungsi untuk mengambil gambar latar belakang
  Future<void> getAbout() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';
    final aboutData = await DioProvider().getAbout(token);
    if (aboutData.containsKey('error')) {
      // Tangani jika terjadi kesalahan saat mengambil gambar latar belakang
      print('Error: ${aboutData['error']}');
    } else {
      setState(() {
        about = Map<String, dynamic>.from(aboutData);
      });
    }
  }
  Future<void> getProfile() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';
    final profileData = await DioProvider().getProfile(token);
    if (profileData.containsKey('error')) {
      // Tangani jika terjadi kesalahan saat mengambil gambar latar belakang
      print('Error: ${profileData['error']}');
    } else {
      setState(() {
        profile = Map<String, dynamic>.from(profileData);
      });
    }
  }

  @override
  void initState() {
    getAbout();
    getProfile();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    Config().init(context);

    return about.isEmpty
        ? Center(
      // Tampilkan indikator loading jika data about kosong
      child: CircularProgressIndicator(),
    )
        : Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SingleChildScrollView(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Hero(
                    tag: about['id'] ?? '',
                    child: Image.asset(
                      'assets/logo.png',
                      width: 56,
                      height: 56,
                      alignment: Alignment.center,
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  about['judul'] ?? '',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                Text(
                  about['subjudul'] ?? '',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
                SizedBox(height: 20),
                Text(
                  about['motto'] ?? '',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                Text(
                  about['submotto'] ?? '',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
                SizedBox(height: 20),
                Text(
                  _removeHtmlTags(about['teks_sejajar_video']) ?? '',
                  style: TextStyle(fontSize: 18),
                ),
                SizedBox(height: 40),
                Text(
                  profile['nama'] ?? '',
                  style: TextStyle(fontSize: 16, color: Colors.black),
                ),
                SizedBox(height: 10),
                Text(
                  'Alamat : ${profile['alamat']?? ''}',
                  style: TextStyle(fontSize: 16, color: Colors.black),
                ),
                SizedBox(height: 10),
                Text(
                  'Email : ${profile['email']?? ''}',
                  style: TextStyle(fontSize: 16, color: Colors.black),
                ),
                SizedBox(height: 10),
                Text(
                  '${profile['no_hp_1'] ?? ''}/${profile['no_hp_2']?? ''}',
                  style: TextStyle(fontSize: 16, color: Colors.black),
                ),
                Text(
                  '${profile['no_telepon_1']?? ''}/${profile['no_telepon_2']?? ''}',
                  style: TextStyle(fontSize: 16, color: Colors.black),
                ),
                SizedBox(height: 5),
                Text(
                  'Facebook : ${profile['facebook']?? ''}',
                  style: TextStyle(fontSize: 16, color: Colors.black),
                ),
                Text(
                  'Instagram : ${profile['instagram']?? ''}',
                  style: TextStyle(fontSize: 16, color: Colors.black),
                ),

                Text(
                  'Youtube : ${profile['youtube']?? ''}',
                  style: TextStyle(fontSize: 16, color: Colors.black),
                ),

                SizedBox(height: 10),

              ],
            ),
          ),
          // Footer section
        ],
      ),
    );

  }
}
