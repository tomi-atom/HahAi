import 'dart:convert';

import 'package:hahai/models/auth_model.dart';
import 'package:hahai/screens/input_absensi.dart';
import 'package:hahai/screens/input_lembur.dart';
import 'package:hahai/screens/input_sakit.dart';
import 'package:hahai/screens/laporan_details.dart';
import 'package:hahai/utils/config.dart';
import 'package:art_sweetalert/art_sweetalert.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/date_symbol_data_local.dart';
import '../main.dart';
import '../providers/dio_provider.dart';

class PageSakit extends StatefulWidget {
  const PageSakit({Key? key}) : super(key: key);

  @override
  State<PageSakit> createState() => _PageSakitState();
}

//enum for rambu kondisi
class _PageSakitState extends State<PageSakit> {

  String url = DioProvider().url;
  DioProvider dioProvider = DioProvider();
  Map<String, dynamic> user = {};
  List<dynamic> favList = [];

  List<dynamic> artikel = [];

  Future<void> getSakit() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';
    final absensi = await dioProvider.getSakit(); // Use the initialized DioProvider
    if (absensi != 'Error') {
      setState(() {
        artikel = json.decode(absensi);
        print(artikel);
      });
    }
  }
  String getStatusText(String status) {
    return status ?? 'Pengajuan';
  }

  Color getStatusColor(String status) {
    switch (status) {
      case 'Ditolak':
        return Colors.red;
      case 'Disetujui':
        return Colors.green;
      default:
        return Colors.yellow; // Warna untuk status null atau 'Pengajuan'
    }
  }
  Future<void> _onRefresh() async {
    // Fetch the updated attendance data
    await getSakit();

    // Optionally, you can show a success message using ArtSweetAlert
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
  void initState() {
    getSakit();
    super.initState();

  }
  @override
  Widget build(BuildContext context) {
    Config().init(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Pengajuan Sakit'),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            FloatingActionButton(
                child: Icon(Icons.add),
                heroTag: null,
                onPressed: ()async{
                  String refresh = await Navigator.push(context, MaterialPageRoute(builder: (context)=> InputSakit()));

                  if(refresh == "refresh"){
                    await _onRefresh();
                  }
                }),
            SizedBox(height: 10),

          ],
        ),
      ),
      body: Container(

        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 15,
            vertical: 15,
          ),
          child: SafeArea(
            child: RefreshIndicator(
              onRefresh: _onRefresh,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
              Expanded(
              child:

              artikel.isNotEmpty
                      ? ListView.builder(
                    shrinkWrap: true,
                    physics: AlwaysScrollableScrollPhysics(),
                    itemCount: artikel.length,
                    itemBuilder: (context, index) {
                      var article = artikel[index];
                      var masuk = DateTime.parse(article['mulai']);
                      var masukIndo =DateFormat.yMMMMd('id').format(masuk);

                      var selesai = DateTime.parse(article['selesai']);
                      var selesaiIndo = DateFormat.yMMMMd('id').format(selesai);


                      return Container(
                        margin: EdgeInsets.symmetric(vertical: 8.0),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.white.withOpacity(0.8),
                            Colors.lightBlueAccent.withOpacity(0.45), // Warna gradasi pertama
                              // Warna gradasi kedua
                            ],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.5),
                              spreadRadius: 2,
                              blurRadius: 4,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                        child: ListTile(
                          leading: article['foto'] != null
                              ? ClipRRect(
                            borderRadius: BorderRadius.circular(8.0),
                            child: Image.network(
                              '$url/${article['foto']}',
                              width: 50,
                              height: 50,
                              fit: BoxFit.cover,
                            ),
                          )
                              : Container(
                            width: 50,
                            height: 50,
                            color: Colors.grey, // Warna abu-abu atau sesuai kebutuhan
                            // Widget atau konten alternatif ketika foto kosong
                          ),


                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Mulai: $masukIndo \nSelesai: $selesaiIndo'),
                              SizedBox(height: 8),


                            ],
                          ),

                        ),
                      );
                    },
                  )
                      : Center(child: Text('Belum Ada Pengajuan Sakit')),
              ),

                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _onDeleteClick(Map<String, dynamic> data) async {
    try {
      FormData formData = FormData.fromMap({
        'sakit_id': data['sakit_id'], // Use 'sakit_id' instead of 'id'
        'user_id': data['user_id'],
      });

      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';

      final response = await Dio().delete(
        '$url/api/sakit/${data['sakit_id']}', // Use DELETE method and include the sakit_id in the URL
        data: formData,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'multipart/form-data',
          },
        ),
      );

      if (response.statusCode == 200) {
        _showSuccessDialog('Data berhasil dihapus!');
      } else {
        _showErrorDialog('Gagal proses data. ${response.data['message']}');
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
      Navigator.pop(context);
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
}
