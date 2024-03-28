import 'dart:convert';

import 'package:hahai/models/auth_model.dart';
import 'package:hahai/screens/input_absensi.dart';
import 'package:hahai/screens/input_izin.dart';
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

class PageIzinKeluarApprove extends StatefulWidget {
  const PageIzinKeluarApprove({Key? key}) : super(key: key);

  @override
  State<PageIzinKeluarApprove> createState() => _PageIzinKeluarApproveState();
}

//enum for rambu kondisi
class _PageIzinKeluarApproveState extends State<PageIzinKeluarApprove> {

  String url = DioProvider().url;
  DioProvider dioProvider = DioProvider();
  Map<String, dynamic> user = {};
  List<dynamic> favList = [];

  List<dynamic> artikel = [];

  Future<void> getApproveIzin() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';
    final data = await dioProvider.getApproveIzin(); // Use the initialized DioProvider
    if (data != 'Error') {
      print(data);
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
    await getApproveIzin();

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
    getApproveIzin();
    super.initState();

  }
  @override
  Widget build(BuildContext context) {
    Config().init(context);


    return Scaffold(
      appBar: AppBar(
        title: Text('Approval Izin Keluar'),
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

                      if (article['tipe_izin'] != 2) {
                        return Container(); // Skip rendering the item
                      }

                      var tanggal = DateTime.parse(article['tanggal']);
                      var masuk = DateTime.parse(article['mulai']);
                      var formattedMasuk = DateFormat('HH:mm').format(masuk);
                      var pulang = DateTime.parse(article['selesai']);
                      var formattedPulang = DateFormat('HH:mm').format(pulang);
                      var formattedDate = DateFormat.yMMMMd('id').format(tanggal);
                      var indonesianDayOfWeek =
                      CustomIndonesianLocale.getIndonesianDayOfWeek(tanggal.weekday);



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
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(8.0),
                            child: Text('$formattedDate \n$indonesianDayOfWeek'),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Mulai: $formattedMasuk \nSelesai: $formattedPulang'),
                              SizedBox(height: 8), // Spacer untuk memberikan jarak antara subtitle dan status
                              Text(
                                'Status: ${getStatusText(Status)}',
                                style: TextStyle(
                                  color: getStatusColor(Status),
                                ),
                              ),
                            ],
                          ),

                        ),
                      );
                    },
                  )
                      : Center(child: Text('Belum Ada Pengajuan Izin Keluar yang Perlu disetujui')),
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
            'Detail Izin',
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
                _buildDetailRow('tanggal', DateFormat.yMMMMd('id').format(DateTime.parse(data['tanggal']))),
                _buildDetailRow('Mulai', DateFormat('H:mm').format(DateTime.parse(data['mulai']))),
                _buildDetailRow('Selesai', DateFormat('H:mm').format(DateTime.parse(data['selesai']))),
                _buildDetailRow('Keterangan',''), // Menambah baris baru untuk informasi pengajuan oleh
                _buildDetailRow('', data['keterangan']), // Menambah baris baru untuk informasi pengajuan oleh
                _buildDetailRow('Status', Status), // Menambah baris baru untuk informasi status

                // Tambahkan informasi lainnya sesuai kebutuhan
              ],
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                _onSetujuClick({
                  'izin_id': data['id'],
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
                  'izin_id': data['id'],
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
        'izin_id': data['izin_id'], // Use 'izin_id' instead of 'id'
        'user_id': data['user_id'],
        'is_approve': data['is_approve'],
      });

      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';

      final response = await Dio().post(
        '$url/api/storeApproveIzin',
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
