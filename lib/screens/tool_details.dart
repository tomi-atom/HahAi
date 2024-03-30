import 'package:flutter/material.dart';
import 'package:html_unescape/html_unescape.dart';
import 'package:intl/intl.dart';

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
          ],
        ),
      ),
    );
  }
}
