import 'dart:convert';
import 'dart:io';

import 'package:art_sweetalert/art_sweetalert.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:hahai/screens/tool_details.dart';
import 'package:hahai/screens/tool_details.dart';
import 'package:hahai/utils/config.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/widgets.dart';
import '../providers/dio_provider.dart';

class ToolPage extends StatefulWidget {
  late final AdSize adSize;

  /// The AdMob ad unit to show.
  ///
  /// TODO: replace this test ad unit with your own ad unit
  final String adUnitId = Platform.isAndroid
  // Use this ad unit on Android...
      ? 'ca-app-pub-3940256099942544/6300978111'
  // ... or this one on iOS.
      : 'ca-app-pub-3940256099942544/2934735716';

  ToolPage({
    super.key,
    this.adSize = AdSize.banner,
  });
  @override
  State<ToolPage> createState() => _ToolPageState();
}

//enum for rambu kondisi
enum FilterRambu { Baik, Rusak }
class _ToolPageState extends State<ToolPage> {

  DioProvider dioProvider = DioProvider();
  String url = DioProvider().url;
  Map<String, dynamic> user = {};
  BannerAd? _bannerAd;
  List<dynamic> tool = [];


  Future<void> getTool() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final data = await dioProvider.getTool();

    if (data != 'Error') {
      print('Cek Artikel $data');

      setState(() {
        // Decode JSON data
        tool = json.decode(data);

        // Display only the first 3 articles
        tool = tool.length > 10 ? tool.sublist(0, 10) : tool;

        print('Cek Artikel $tool');
      });
    }
  }
  @override
  void initState() {
    getTool();
    super.initState();
    _loadAd();
  }
  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }
  void _loadAd() {
    final bannerAd = BannerAd(
      size: widget.adSize,
      adUnitId: widget.adUnitId,
      request: const AdRequest(),
      listener: BannerAdListener(
        // Called when an ad is successfully received.
        onAdLoaded: (ad) {
          if (!mounted) {
            ad.dispose();
            return;
          }
          setState(() {
            _bannerAd = ad as BannerAd;
          });
        },
        // Called when an ad request failed.
        onAdFailedToLoad: (ad, error) {
          debugPrint('BannerAd failed to load: $error');
          ad.dispose();
        },
      ),
    );

    // Start loading.
    bannerAd.load();
  }
  Future<void> _onRefresh() async {
    await getTool();
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
        title: Text('Detail Tool'),
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
                            child: tool.isNotEmpty
                                ? ListView.builder(
                              shrinkWrap: true,
                              physics:AlwaysScrollableScrollPhysics(),
                              itemCount: tool.length,
                              itemBuilder: (context, index) {
                                var article = tool[index];
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
                                          builder: (context) => DetailToolPage(
                                            toolData: article,
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
                          SizedBox(
                            width: widget.adSize.width.toDouble(),
                            height: widget.adSize.height.toDouble(),
                            child: _bannerAd == null
                            // Nothing to render yet.
                                ? SizedBox()
                            // The actual ad.
                                : AdWidget(ad: _bannerAd!),
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
