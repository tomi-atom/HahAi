import 'dart:convert';

import 'package:hahai/models/auth_model.dart';
import 'package:hahai/screens/input_absensi.dart';
import 'package:hahai/screens/input_cuti.dart';
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

class PageCuti extends StatefulWidget {
  const PageCuti({Key? key}) : super(key: key);

  @override
  State<PageCuti> createState() => _PageCutiState();
}

//enum for rambu kondisi
class _PageCutiState extends State<PageCuti> {
  DioProvider dioProvider = DioProvider();
  String url = DioProvider().url;

  Map<String, dynamic> user = {};
  List<dynamic> favList = [];

  List<dynamic> artikel = [];
  Future<void> _onRefresh() async {
    // Fetch the updated attendance data
    await getCuti();

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
  Future<void> getCuti() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';
    final data = await dioProvider.getCuti(); // Use the initialized DioProvider
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



  @override
  void initState() {
    getCuti();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    Config().init(context);


    return Scaffold(
      appBar: AppBar(
        title: Text('Pengajuan Cuti'),
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
                  String refresh = await Navigator.push(context, MaterialPageRoute(builder: (context)=> InputCuti()));

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
                  // Tambahkan widget kondisional untuk menampilkan pesan "Data tidak ditemukan"

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


                      var status = article['status'];
                      var jabatan = article['jabatan'];
                      var bagian = article['bagian'];
                      var user_ganti = article['name'];

                      return GestureDetector(
                        onTap: () {
                          // Use showDialog to display details
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: Text('Detail Persetujuan Cuti'),
                                content: SingleChildScrollView(
                                  child: Container(
                                    padding: EdgeInsets.all(8.0), // Adjust the padding as needed
                                    height: 200.0, // Set a fixed height or use MediaQuery to get the screen height
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: article['persetujuan_cuti']
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
                                  if (article['persetujuan_cuti'].isEmpty )
                                    ElevatedButton(
                                    onPressed: () {
                                      _onDeleteClick({
                                        'cuti_id': article['id'],
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

                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Mulai: $masukIndo \nSelesai: $selesaiIndo'),
                                Text('Jabatan: $jabatan'),
                                Text('Bagian: $bagian'),
                                Text('Pengganti: $user_ganti'),

                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  )
                      : Center(child: Text('Belum Ada Pengajuan Cuti')),
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
        'cuti_id': data['cuti_id'], // Use 'cuti_id' instead of 'id'
        'user_id': data['user_id'],
      });

      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';

      final response = await Dio().delete(
        '$url/api/cuti/${data['cuti_id']}', // Use DELETE method and include the cuti_id in the URL
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
