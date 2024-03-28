import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:art_sweetalert/art_sweetalert.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/auth_model.dart';
import '../providers/dio_provider.dart';
import '../utils/config.dart';

class InputSakit extends StatefulWidget {
  @override
  _InputSakitState createState() => _InputSakitState();


}

class _InputSakitState extends State<InputSakit> {
  late TextEditingController _mulai;
  late TextEditingController _selesai;
  late TextEditingController _keterangan;
  String? imagePath;
  late Dio dio;
  String url = DioProvider().url;
  Map<String, dynamic> user = {};

  @override
  void initState() {
    super.initState();
    _mulai = TextEditingController();
    _selesai = TextEditingController();
    _keterangan = TextEditingController();
    dio = Dio();
  }
  _imgCmr() async {
    final XFile? image = await ImagePicker().pickImage(source: ImageSource.camera);
    setState(() {
      imagePath = image?.path;
    });
    debugPrint('path: ${image?.path}');
  }
  _imgGalery() async {
    final XFile? image = await ImagePicker().pickImage(source: ImageSource.gallery);
    setState(() {
      imagePath = image?.path;
    });
    debugPrint('path: ${image?.path}');
  }
  _submitReport() async {
    try {
      if (_mulai.text.isEmpty || _selesai.text.isEmpty) {
        _showErrorDialog('Tolong Lengkapi Data Pengajuan.');
        return;
      }

      DateTime startDate = DateFormat('yyyy-MM-dd').parse(_mulai.text);
      DateTime endDate = DateFormat('yyyy-MM-dd').parse(_selesai.text);
      int dayDifference = endDate.difference(startDate).inDays;

      if (dayDifference > 3 && (imagePath == null || imagePath!.isEmpty)) {
        _showErrorDialog('Mohon sertakan foto surat dokter jika Lebih dari 3 hari.');
        return;
      }

      FormData formData = FormData.fromMap({
        'mulai': _mulai.text,
        'selesai': _selesai.text,
        'image': imagePath != null ? await MultipartFile.fromFile(imagePath!) : null,
      });



      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';

      final response = await Dio().post(
        '$url/api/storeSakit',
        data: formData,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'multipart/form-data',
          },
        ),
      );

      if (response.statusCode == 200) {
        _showSuccessDialog('Data berhasil dikirim!');
      } else {
        _showErrorDialog('Gagal mengirim data. ${response.data['message']}');
      }
    } catch (error) {
      print('Terjadi kesalahan: $error');
      _showErrorDialog('Terjadi kesalahan: $error');
    }
  }

  _showSuccessDialog(String message) {
    ArtSweetAlert.show(
      context: context,
      artDialogArgs: ArtDialogArgs(
        type: ArtSweetAlertType.success,
        title: "Berhasil",
        text: message,
        confirmButtonText: "OK",
      ),
    ).then((value) {
      Navigator.pop(context, "refresh");
    });
  }


  _showErrorDialog(String message) {
    ArtSweetAlert.show(
      context: context,
      artDialogArgs: ArtDialogArgs(
        type: ArtSweetAlertType.danger,
        title: "Error",
        text: message,
      ),
    );
  }


  @override
  void dispose() {
    super.dispose();
  }
  Future<void> _selectDate(BuildContext context, TextEditingController controller) async {
    DateTime currentDate = DateTime.now();
    DateTime minDate = currentDate.add(Duration(days: 14));
    DateTime maxDate = currentDate.add(Duration(days: 360));

    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: currentDate,
      firstDate: currentDate,
      lastDate: maxDate,
    );

    if (pickedDate != null) {
      setState(() {
        controller.text = DateFormat('yyyy-MM-dd').format(pickedDate);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pengajuan Sakit'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: _mulai,
              onTap: () {
                _selectDate(context, _mulai);
              },
              readOnly: true,
              decoration: InputDecoration(
                labelText: 'Mulai',
                border: OutlineInputBorder(),
              ),
              maxLines: 1,
            ),
            SizedBox(height: 20.0),
            TextFormField(
              controller: _selesai,
              onTap: () {
                _selectDate(context, _selesai);
              },
              readOnly: true,
              decoration: InputDecoration(
                labelText: 'Selesai',
                border: OutlineInputBorder(),
              ),
              maxLines: 1,
            ),
            SizedBox(height: 20.0),
            Text('Surat Dokter (Jika 3 Hari Atau Lebih)'),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _imgCmr,
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.zero,
                      backgroundColor:Config.primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      // Ganti dengan warna hijau yang kamu inginkan
                    ),
                    child: Ink(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: Container(
                        alignment: Alignment.center,
                        padding: EdgeInsets.symmetric(vertical: 16.0),
                        child: Text(
                          'Ambil Foto',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 10), // Jarak antara tombol Ambil Foto dan tombol Galeri
                Expanded(
                  child: ElevatedButton(
                    onPressed: _imgGalery,
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.zero,
                      backgroundColor:Config.primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      // Ganti dengan warna hijau yang kamu inginkan
                    ),
                    child: Ink(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: Container(
                        alignment: Alignment.center,
                        padding: EdgeInsets.symmetric(vertical: 16.0),
                        child: Text(
                          'Galeri',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            if (imagePath != null) Image.file(File(imagePath!)),
            SizedBox(height: 30.0),
            ElevatedButton(
              onPressed: _submitReport,
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.zero, backgroundColor:Config.primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ), // Ganti dengan warna hijau yang kamu inginkan
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
                    'Simpan',
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
