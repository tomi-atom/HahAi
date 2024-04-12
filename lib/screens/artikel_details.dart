import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:html_unescape/html_unescape.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/dio_provider.dart';
import '../utils/ad_manager.dart';

class DetailArtikelPage extends StatefulWidget {
  final AdSize adSize;
  final Map<String, dynamic> artikelData;

  const DetailArtikelPage({
    Key? key,
    this.adSize = AdSize.banner,
    required this.artikelData,
  }) : super(key: key);

  @override
  State<DetailArtikelPage> createState() => _DetailArtikelPageState();
}

class _DetailArtikelPageState extends State<DetailArtikelPage> {
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
          debugPrint('Berhasil Tampilkan Iklan');

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
        title: Text('Detail Artikel'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Hero(
              tag: widget.artikelData['id'],
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15.0),
                child: Image.network(
                  '$url/${widget.artikelData['gambar']}',
                  width: double.infinity,
                  height: 200,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            SizedBox(height: 20),
            Text(
              widget.artikelData['judul'],
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Text(
              widget.artikelData['written_by'],
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              DateFormat('dd-MM-yyyy').format(DateTime.parse( widget.artikelData['published_at'])), // Published date
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            SizedBox(height: 20),
            Text(
              _removeHtmlTags(widget.artikelData['body']),// Text content without HTML tags
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 20.0),
            SizedBox(
              width: widget.adSize.width.toDouble(),
              height: widget.adSize.height.toDouble(),
              child: _bannerAd == null ? SizedBox() : AdWidget(ad: _bannerAd!),
            ),
            SizedBox(height: 20.0),



          ],
        ),
      ),
    );
  }
}
