import 'package:flutter/material.dart';
import 'package:html_unescape/html_unescape.dart';

import '../providers/dio_provider.dart';

class DetailArtikel extends StatelessWidget {
  final Map<String, dynamic> artikelData;

  const DetailArtikel({Key? key, required this.artikelData}) : super(key: key);

  String _removeHtmlTags(String htmlString) {
    final HtmlUnescape htmlUnescape = HtmlUnescape();
    return htmlUnescape.convert(htmlString.replaceAll(RegExp(r'<[^>]*>'), ''));
  }

  @override
  Widget build(BuildContext context) {
    late final HtmlUnescape htmlUnescape;
    String url = DioProvider().url;
    return Scaffold(
      appBar: AppBar(
        title: Text('Detail'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Hero(
              tag: artikelData['id'], // Unique tag for the Hero animation
              child: Image.network(
                '$url/${artikelData['gambar']}', // Path to your article image
                width: double.infinity,
                height: 200,
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(height: 20),
            Text(
              artikelData['judul'], // Article title
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              artikelData['published_at'], // Published date
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            SizedBox(height: 20),
            Text(
              _removeHtmlTags(artikelData['body']),// Text content without HTML tags
              style: TextStyle(fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }
}
