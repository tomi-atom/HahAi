import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:html_unescape/html_unescape.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../providers/dio_provider.dart';

class DetailToolPage extends StatelessWidget {
  final Map<String, dynamic> toolData;

  const DetailToolPage({Key? key, required this.toolData}) : super(key: key);

  String _removeHtmlTags(String htmlString) {
    final HtmlUnescape htmlUnescape = HtmlUnescape();
    return htmlUnescape.convert(htmlString.replaceAll(RegExp(r'<[^>]*>'), ''));
  }



  @override
  Widget build(BuildContext context) {
    late final HtmlUnescape htmlUnescape;
    String url = DioProvider().url;
    AdManager().initialize();
    return Scaffold(
      appBar: AppBar(
        title: Text('Detail Tool AI'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Hero(
              tag: toolData['id'], // Unique tag for the Hero animation
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15.0), // Adjust the value as needed
                child: Image.network(
                  '$url/${toolData['gambar']}', // Path to your article image
                  width: double.infinity,
                  height: 200,
                  fit: BoxFit.cover,
                ),
              ),
            ),

            SizedBox(height: 20),
            Text(
              toolData['judul'], // Article title
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              DateFormat('dd-MM-yyyy').format(DateTime.parse(toolData['published_at'])), // Published date
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            SizedBox(height: 20),
            Text(
              _removeHtmlTags(toolData['body']),// Text content without HTML tags
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: () async {
                if (toolData.containsKey('website') && toolData['website'] != null) {
                  final url = toolData['website'];
                  if (await canLaunch(url)) {
                    await launch(url);
                  } else {
                    throw 'Could not launch $url';
                  }
                } else {
                  throw 'Website URL is not provided';
                }
              },
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.zero,
                backgroundColor:Colors.blue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
              child: Ink(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: Container(
                  constraints: BoxConstraints(maxWidth: double.infinity),
                  alignment: Alignment.center,
                  padding: EdgeInsets.symmetric(vertical: 16.0),
                  child: Text(
                    'Lihat Website',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),

            SizedBox(height: 20), // Add some space between the content and the ad

            // AdMob Banner Ad
            Container(
              alignment: Alignment.center,
              child: AdWidget(ad: AdManager().bannerAd),
              width: AdSize.banner.width.toDouble(),
              height: AdSize.banner.height.toDouble(),
            ),

          ],
        ),
      ),
    );
  }
}
class AdManager {
  static final AdManager _instance = AdManager._internal();

  factory AdManager() => _instance;

  AdManager._internal();

  late BannerAd _bannerAd;

  BannerAd get bannerAd => _bannerAd;

  void initialize() {
    _bannerAd = BannerAd(
      adUnitId: Platform.isAndroid
          ? 'ca-app-pub-7319269804560504/8512599311'
          : 'ca-app-pub-3940256099942544/4411468910',
      size: AdSize.banner,
      request: AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) {
          // Ad has been loaded
        },
        onAdFailedToLoad: (ad, error) {
          // Ad failed to load
          ad.dispose();
        },
      ),
    );

    _loadBannerAd();
  }

  void _loadBannerAd() {
    _bannerAd.load();
  }
}