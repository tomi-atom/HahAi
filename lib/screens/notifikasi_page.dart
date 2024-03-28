import 'dart:convert';

import 'package:hahai/models/auth_model.dart';
import 'package:hahai/screens/input_absensi.dart';
import 'package:hahai/screens/input_lembur.dart';
import 'package:hahai/screens/laporan_details.dart';
import 'package:hahai/utils/config.dart';
import 'package:art_sweetalert/art_sweetalert.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/date_symbol_data_local.dart';
import '../main.dart';
import '../providers/dio_provider.dart';

class NotifikasiPage extends StatefulWidget {
  const NotifikasiPage({Key? key}) : super(key: key);

  @override
  State<NotifikasiPage> createState() => _NotifikasiPageState();
}

//enum for rambu kondisi
class _NotifikasiPageState extends State<NotifikasiPage> {

  DioProvider dioProvider = DioProvider(); // Initialize DioProvider once
  Map<String, dynamic> user = {};
  List<dynamic> favList = [];

  List<dynamic> artikel = [];
  Future<void> _onRefresh() async {
    // Fetch the updated attendance data
    await getAbsensi();

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
  Future<void> getAbsensi() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';
    final absensi = await dioProvider.getNotifikasi(); // Use the initialized DioProvider
    if (absensi != 'Error') {
      setState(() {
        artikel = json.decode(absensi);
        print(artikel);
      });
    }
  }
  @override
  void initState() {
    getAbsensi();
    super.initState();

  }
  @override
  Widget build(BuildContext context) {
    Config().init(context);


    return Scaffold(
      appBar: AppBar(
        title: Text('Notifikasi'),
        automaticallyImplyLeading: false,
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

                                  title: Text(article['notifikasi']),

                                ),
                              );
                            },
                          )
                              : Center(child: Text('Belum Ada Notifikasi')),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
