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

class InputIzin extends StatefulWidget {
  @override
  _InputIzinState createState() => _InputIzinState();


}

class _InputIzinState extends State<InputIzin> {
  late TextEditingController _tanggal;
  late TextEditingController _mulai;
  late TextEditingController _selesai;
  late TextEditingController _keterangan;
  Map<String, dynamic> user = {};

  late Dio dio;
  String url = DioProvider().url;

  @override
  void initState() {
    super.initState();
    _tanggal = TextEditingController(text: _getCurrentDate());
    _mulai = TextEditingController();
    _selesai = TextEditingController();
    _keterangan = TextEditingController();
    dio = Dio();
  }

  _submitReport() async {
    try {
      if (_tanggal.text.isEmpty || _mulai.text.isEmpty || _selesai.text.isEmpty || _keterangan.text.isEmpty) {
        _showErrorDialog('Tolong Lengkapi Data Pengajuan.');
        return;
      }

      FormData formData = FormData.fromMap({

        'tanggal': _tanggal.text,
        'mulai': _mulai.text,
        'selesai': _selesai.text,
        'keterangan': _keterangan.text,
        'tipe_izin': 1,
      });


      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';

      final response = await Dio().post(
        '$url/api/storeIzin',
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
  String _getCurrentDate() {
    return DateFormat('y-MM-dd').format(DateTime.now());
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
  Future<void> _selectTime(BuildContext context, TextEditingController controller) async {
    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (pickedTime != null) {
      DateTime selectedTime = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day,
          pickedTime.hour, pickedTime.minute);
      setState(() {
        controller.text = DateFormat('HH:mm').format(selectedTime);
      });
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pengajuan Izin Harian'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _tanggal,
              onTap: () {
                _selectDate(context, _tanggal);
              },
              readOnly: true,
              enabled: false, // Menonaktifkan editing
              decoration: InputDecoration(
                labelText: 'Tanggal',
                border: OutlineInputBorder(),
              ),
              maxLines: 1,
            ),
            SizedBox(height: 20.0),
            TextFormField(
              controller: _mulai,
              onTap: () {
                _selectTime(context, _mulai);
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
                _selectTime(context, _selesai);
              },
              readOnly: true,
              decoration: InputDecoration(
                labelText: 'Selesai',
                border: OutlineInputBorder(),
              ),
              maxLines: 1,
            ),
            SizedBox(height: 20.0),
            TextField(
              controller: _keterangan,
              decoration: InputDecoration(
                labelText: 'Keterangan',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
            SizedBox(height: 20.0),
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
