import 'dart:convert';

import 'package:hahai/models/auth_model.dart';
import 'package:hahai/screens/input_absensi.dart';
import 'package:hahai/screens/input_lembur.dart';
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

class PageLembur extends StatefulWidget {
  const PageLembur({Key? key}) : super(key: key);

  @override
  State<PageLembur> createState() => _PageLemburState();
}

//enum for rambu kondisi
class _PageLemburState extends State<PageLembur> {

  String url = DioProvider().url;
  DioProvider dioProvider = DioProvider(); // Initialize DioProvider once
  Map<String, dynamic> user = {};
  List<dynamic> favList = [];

  List<dynamic> artikel = [];

  Future<void> getLembur() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';
    final data = await dioProvider.getLembur(); // Use the initialized DioProvider
    if (data != 'Error') {
      setState(() {
        artikel = json.decode(data);
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
    await getLembur();

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
    getLembur();
    super.initState();

  }
  @override
  Widget build(BuildContext context) {
    Config().init(context);


    return Scaffold(
      appBar: AppBar(
        title: Text('Pengajuan Lembur'),
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
                  String refresh = await Navigator.push(context, MaterialPageRoute(builder: (context)=> InputLembur()));

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
                  var tanggal = DateTime.parse(article['tanggal']);
                  var masuk = DateTime.parse(article['mulai']);
                  var formattedMasuk = DateFormat('HH:mm').format(masuk);
                  var pulang = DateTime.parse(article['selesai']);
                  var formattedPulang = DateFormat('HH:mm').format(pulang);
                  var formattedDate = DateFormat.yMMMMd('id').format(tanggal);
                  var indonesianDayOfWeek =
                  CustomIndonesianLocale.getIndonesianDayOfWeek(tanggal.weekday);

                      return GestureDetector(
                    onTap: () {
                      // Use showDialog to display details
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text('Detail Persetujuan Lembur'),
                            content: SingleChildScrollView(
                              child: Container(
                                padding: EdgeInsets.all(8.0), // Adjust the padding as needed
                                height: 200.0, // Set a fixed height or use MediaQuery to get the screen height
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: article['persetujuan_lembur']
                                      .map<Widget>((approval) {
                                    return Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        if (approval['user'] != null) // Check if user is not null
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text('Nama: ${approval['user']['name']}'),
                                            ],
                                          ),
                                        Text(
                                          'Status: ${approval['is_approve'] == 1 ? 'Setuju' : 'Ditolak'}',
                                          style: TextStyle(
                                            color: approval['is_approve'] == 1 ? Colors.green : Colors.red,
                                          ),
                                        ),

                                        Divider(), // Add a divider between each approval
                                      ],
                                    );
                                  }).toList(),
                                ),
                              ),
                            ),
                            actions: <Widget>[
                              if (article['persetujuan_lembur'].isEmpty)

                                ElevatedButton(
                                onPressed: () {
                                  _onDeleteClick({
                                    'lembur_id': article['id'],
                                    'user_id': article['user_id'],
                                  });
                                  Navigator.of(context).pop(); // Tutup dialog
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                ),
                                child: Text('Batalkan'),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: Text('Close'),
                              ),
                            ],
                          );
                        },
                      );

                    },
                    child: Container(
                      margin: EdgeInsets.symmetric(vertical: 8.0),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.white.withOpacity(0.8),
                            Colors.lightBlueAccent.withOpacity(0.45),
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
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(8.0),
                          child: Text('$formattedDate \n$indonesianDayOfWeek'),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Mulai: $formattedMasuk \nSelesai: $formattedPulang'),
                            SizedBox(height: 8),

                          ],
                        ),
                      ),
                    ),
                  );
                },
              )

                  : Center(child: Text('Belum Ada Pengajuan Lembur')),
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
        'lembur_id': data['lembur_id'], // Use 'lembur_id' instead of 'id'
        'user_id': data['user_id'],
      });

      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';

      final response = await Dio().delete(
        '$url/api/lembur/${data['lembur_id']}', // Use DELETE method and include the lembur_id in the URL
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
