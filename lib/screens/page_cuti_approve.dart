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

class PageCutiApprove extends StatefulWidget {
  const PageCutiApprove({Key? key}) : super(key: key);

  @override
  State<PageCutiApprove> createState() => _PageCutiApproveState();
}

//enum for rambu kondisi
class _PageCutiApproveState extends State<PageCutiApprove> {
  DioProvider dioProvider = DioProvider();
  String url = DioProvider().url;

  Map<String, dynamic> user = {};
  List<dynamic> favList = [];

  List<dynamic> artikel = [];
  Future<void> _onRefresh() async {
    // Fetch the updated attendance data
    await getApproveCuti();

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
  Future<void> getApproveCuti() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';
    final data = await dioProvider.getApproveCuti(); // Use the initialized DioProvider
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
    getApproveCuti();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    Config().init(context);


    return Scaffold(
      appBar: AppBar(
        title: Text('Approval Cuti'),
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


                      var user_name = article['user_name'];

                      var isApprove = article['is_approve'];
                      String Status = '';
                      if (isApprove == null) {
                        Status =  'Pengajuan';
                      } else if (isApprove == 1) {
                        Status =  'Disetujui';
                      } else if (isApprove == 0) {
                        Status =  'Ditolak';
                      } else {
                        Status ='Status tidak diketahui';
                      }

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
                          onTap: () {
                            _showDetailDialog(context, artikel[index]);
                          },
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Nama: $user_name',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'Waktu: $masukIndo - $selesaiIndo',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),

                              SizedBox(height: 12), // Spacer untuk memberikan jarak antara subtitle dan status
                              Text(
                                'Status: ${getStatusText(Status)}',
                                style: TextStyle(
                                  color: getStatusColor(Status),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),


                        ),
                      );
                    },
                  )
                      : Center(child: Text('Belum Ada Pengajuan Cuti yang Perlu disetujui')),
              ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
  void _showDetailDialog(BuildContext context, Map<String, dynamic> data) {
    var isApprove = data['is_approve'];
    String Status = '';
    if (isApprove == null) {
      Status =  'Pengajuan';
    } else if (isApprove == 1) {
      Status =  'Disetujui';
    } else if (isApprove == 0) {
      Status =  'Ditolak';
    } else {
      Status ='Status tidak diketahui';
    }
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Detail Cuti',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDetailRow('Pengajuan Oleh', data['user_name']), // Menambah baris baru untuk informasi pengajuan oleh
                _buildDetailRow('Mulai', DateFormat.yMMMMd('id').format(DateTime.parse(data['mulai']))),
                _buildDetailRow('Selesai', DateFormat.yMMMMd('id').format(DateTime.parse(data['selesai']))),
                _buildDetailRow('Jabatan', data['jabatan']),
                _buildDetailRow('Bagian', data['bagian']),
                _buildDetailRow('Pengganti', data['pengganti_name']), // Menggunakan 'pengganti_name' dari data
                _buildDetailRow('Status', Status), // Menambah baris baru untuk informasi status

                // Tambahkan informasi lainnya sesuai kebutuhan
              ],
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                _onSetujuClick({
                  'cuti_id': data['id'],
                  'user_id': data['user_id'],
                  'is_approve': 1,
                });
                Navigator.of(context).pop(); // Tutup dialog
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
              ),
              child: Text('Setuju'),
            ),
            ElevatedButton(
              onPressed: () {
                _onSetujuClick({
                  'cuti_id': data['id'],
                  'user_id': data['user_id'],
                  'is_approve': 0,
                });
                Navigator.of(context).pop(); // Tutup dialog
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              child: Text('Tolak'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(value),
        ],
      ),
    );
  }
  void _onSetujuClick(Map<String, dynamic> data) async {
    try {
      FormData formData = FormData.fromMap({
        'cuti_id': data['cuti_id'], // Use 'cuti_id' instead of 'id'
        'user_id': data['user_id'],
        'is_approve': data['is_approve'],
      });

      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';

      final response = await Dio().post(
        '$url/api/storeApproveCuti',
        data: formData,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'multipart/form-data',
          },
        ),
      );

      if (response.statusCode == 200) {
        if(data['is_approve'] ==1){
          _showSuccessDialog('Data berhasil disetujui!');

        }else{
          _showSuccessDialog('Data berhasil ditolak!');

        }
      } else {
        _showErrorDialog('Gagal Proses data. ${response.data['message']}');
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
