import 'package:flutter/material.dart';
import 'package:html_unescape/html_unescape.dart';

import '../providers/dio_provider.dart';

class DetailCuti extends StatelessWidget {
  final Map<String, dynamic> artikelData;

  const DetailCuti({Key? key, required this.artikelData}) : super(key: key);

  String _removeHtmlTags(String htmlString) {
    final HtmlUnescape htmlUnescape = HtmlUnescape();
    return htmlUnescape.convert(htmlString.replaceAll(RegExp(r'<[^>]*>'), ''));
  }

  @override
  Widget build(BuildContext context) {
    final String url = DioProvider().url;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Laporan'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Hero(
              tag: artikelData['id'].toString(), // Unique tag for the Hero animation
              child: Image.network(
                '$url/${artikelData['foto']}', // Path to your article image
                width: double.infinity,
                height: 200,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              artikelData['keterangan'].toString(), // Article title
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              artikelData['created_at'].toString(), // Published date
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 20),
            Text(
              _removeHtmlTags(artikelData['kondisi'].toString()), // Text content without HTML tags
              style: const TextStyle(fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }
}
