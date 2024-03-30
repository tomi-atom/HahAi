import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:html_unescape/html_unescape.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/dio_provider.dart';
import '../utils/ad_manager.dart';

class DetailToolPage extends StatefulWidget {
  final AdSize adSize;
  final Map<String, dynamic> toolData;

  const DetailToolPage({
    Key? key,
    this.adSize = AdSize.banner,
    required this.toolData,
  }) : super(key: key);

  @override
  State<DetailToolPage> createState() => _DetailToolPageState();
}

class _DetailToolPageState extends State<DetailToolPage> {
  BannerAd? _bannerAd;

  @override
  void initState() {
    super.initState();
    _loadAd();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  void _loadAd() {
    _bannerAd = AdManager.createBannerAd(widget.adSize, BannerAdListener(
      onAdLoaded: (ad) {
        if (!mounted) {
          ad.dispose();
          return;
        }
        setState(() {
          _bannerAd = ad as BannerAd?;
        });
      },
      onAdFailedToLoad: (ad, error) {
        debugPrint('BannerAd failed to load: $error');
        ad.dispose();
      },
    ));

    _bannerAd?.load();
  }

  String _removeHtmlTags(String htmlString) {
    final HtmlUnescape htmlUnescape = HtmlUnescape();
    return htmlUnescape.convert(htmlString.replaceAll(RegExp(r'<[^>]*>'), ''));
  }

  @override
  Widget build(BuildContext context) {
    String url = DioProvider().url;
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
              tag: widget.toolData['id'],
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15.0),
                child: Image.network(
                  '$url/${widget.toolData['gambar']}',
                  width: double.infinity,
                  height: 200,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            SizedBox(height: 20),
            Text(
              widget.toolData['judul'],
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              DateFormat('dd-MM-yyyy').format(DateTime.parse( widget.toolData['published_at'])), // Published date
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            SizedBox(height: 20),
            Text(
              _removeHtmlTags(widget.toolData['body']),// Text content without HTML tags
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 20.0),
            SizedBox(
              width: widget.adSize.width.toDouble(),
              height: widget.adSize.height.toDouble(),
              child: _bannerAd == null ? SizedBox() : AdWidget(ad: _bannerAd!),
            ),
            SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: () async {
                if ( widget.toolData.containsKey('website') && widget.toolData['website'] != null) {
                  final url =  widget.toolData['website'];
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


          ],
        ),
      ),
    );
  }
}
