import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:art_sweetalert/art_sweetalert.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/auth_model.dart';
import '../providers/dio_provider.dart';
import '../utils/config.dart';

class InputCuti2 extends StatefulWidget {
  @override
  _InputCuti2State createState() => _InputCuti2State();
}
class TipeCuti {
  final String id;
  final String namaTipeCuti;

  TipeCuti(this.id, this.namaTipeCuti);
}


class _InputCuti2State extends State<InputCuti2> {
  late TextEditingController _mulai;
  late TextEditingController _selesai;
  late TextEditingController _jabatan;
  late TextEditingController _bagian;
  late Dio dio;
  String? imagePath;
  late LocationSettings locationSettings;
  String url = DioProvider().url;
  late String selectedTipeCuti;
  Map<String, dynamic> user = {};


  late List<TipeCuti> TipeCutiOptions = [];



  @override
  void initState() {
    super.initState();
    _mulai = TextEditingController();
    _selesai = TextEditingController();
    _jabatan = TextEditingController();
    _bagian = TextEditingController();
    dio = Dio();
    selectedTipeCuti = '';

    _fetchTipeCuti();
  }
  List<dynamic> tipeCuti = [];
  Future<void> _fetchTipeCuti() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';
      final rambu = await DioProvider().getTipeCuti();

      if (rambu != 'Error') {
        final List<dynamic> tipeCutiData = json.decode(rambu);

        setState(() {
          TipeCutiOptions = tipeCutiData.map((data) =>
              TipeCuti(data['id'].toString(), data['name'].toString()))
              .toList();

          // Check if user's name exists in TipeCutiOptions
          String userNama = user['name'] ?? '';
          TipeCutiOptions.removeWhere((tipeCuti) => tipeCuti.namaTipeCuti == userNama);

          selectedTipeCuti =
          TipeCutiOptions.isNotEmpty ? TipeCutiOptions.first.id : '';
        });
      } else {
        // Handle the case where the response is 'Error'
        print('Error fetching tipeCuti data');
      }
    } catch (error) {
      print('Terjadi kesalahan: $error');
      // Handle other errors, e.g., network errors
    }
  }


  _submitReport() async {
    try {

      if (_mulai.text.isEmpty || _selesai.text.isEmpty || _jabatan.text.isEmpty || _bagian.text.isEmpty || selectedTipeCuti.isEmpty) {
        _showErrorDialog('Tolong Lengkapi Data Pengajuan.');
        return;
      }
      FormData formData = FormData.fromMap({

        'mulai': _mulai.text,
        'selesai': _selesai.text,
        'jabatan': _jabatan.text,
        'bagian': _bagian.text,
        'user_ganti': selectedTipeCuti,
      });


      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';

      final response = await Dio().post(
        '$url/api/storeCuti',
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
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (pickedDate != null && pickedDate != DateTime.now()) {
      setState(() {
        controller.text = DateFormat('yyyy-MM-dd').format(pickedDate);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pengajuan Cuti'),
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
            TextField(
              controller: _jabatan,
              decoration: InputDecoration(
                labelText: 'Jabatan',
                border: OutlineInputBorder(),
              ),
              maxLines: 1,
            ),
            SizedBox(height: 20.0),
            TextField(
              controller: _bagian,
              decoration: InputDecoration(
                labelText: 'Bagian',
                border: OutlineInputBorder(),
              ),
              maxLines: 1,
            ),
            SizedBox(height: 20.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Pilih TipeCuti:',
                  style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(width: 10), // Jarak antara teks dan dropdown
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.3),
                          spreadRadius: 2,
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12.0),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: selectedTipeCuti,
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 16.0,
                          ),
                          icon: Icon(Icons.arrow_drop_down),
                          items: TipeCutiOptions.map((TipeCuti tipeCuti) {
                            return DropdownMenuItem<String>(
                              value: tipeCuti.id,
                              child: Text(
                                tipeCuti.namaTipeCuti,
                                style: TextStyle(
                                  fontSize: 16.0,
                                ),
                              ),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            setState(() {
                              selectedTipeCuti = newValue ?? '';
                              // Lakukan sesuatu saat pilihan tipeCuti berubah
                            });
                          },
                        ),

                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),
            if (imagePath != null) Image.file(File(imagePath!)),
            SizedBox(height: 25.0),
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
