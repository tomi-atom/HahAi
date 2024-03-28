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

class PageRekap extends StatefulWidget {
  const PageRekap({Key? key}) : super(key: key);

  @override
  State<PageRekap> createState() => _PageRekapState();
}

//enum for rambu kondisi
class _PageRekapState extends State<PageRekap> {

  DioProvider dioProvider = DioProvider(); // Initialize DioProvider once
  Map<String, dynamic> user = {};
  List<dynamic> favList = [];
  int selectedMonth = DateTime.now().month;
  int selectedYear = DateTime.now().year;
  List<dynamic> artikel = [];
  Future<void> _onRefresh() async {
    await getAbsensi(selectedMonth, selectedYear);
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

  Future<void> getAbsensi(int month, int year) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';
    final absensi = await dioProvider.getAbsensi();
    if (absensi != 'Error') {
      setState(() {
        // Filter data absensi berdasarkan bulan dan tahun
        artikel = json.decode(absensi).where((data) {
          DateTime tanggal = DateTime.parse(data['tanggal']);
          return tanggal.month == month && tanggal.year == year;
        }).toList();
      });
    }
  }
  @override
  void initState() {
    getAbsensi(selectedMonth, selectedYear);
    super.initState();

  }
  @override
  Widget build(BuildContext context) {
    Config().init(context);


    return Scaffold(
      appBar: AppBar(
        title: Text('Rekap Absensi'),
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

                  Row(
                    children: [
                      DropdownButton<int>(
                        value: selectedMonth,
                        onChanged: (newValue) {
                          setState(() {
                            selectedMonth = newValue!;
                          });
                          _onRefresh();
                        },
                        items: List.generate(12, (index) {
                          return DropdownMenuItem<int>(
                            value: index + 1,
                            child: Text(DateFormat.MMMM().format(DateTime(2000, index + 1))),
                          );
                        }),
                      ),
                      DropdownButton<int>(
                        value: selectedYear,
                        onChanged: (newValue) {
                          setState(() {
                            selectedYear = newValue!;
                          });
                          _onRefresh();
                        },
                        items: List.generate(5, (index) {
                          return DropdownMenuItem<int>(
                            value: DateTime.now().year - index,
                            child: Text('${DateTime.now().year - index}'),
                          );
                        }),
                      ),
                    ],
                  ),

              Expanded(
                  child: artikel.isNotEmpty
                          ? ListView.builder(
                        shrinkWrap: true,
                        physics: AlwaysScrollableScrollPhysics(),
                        itemCount: artikel.length,
                        itemBuilder: (context, index) {
                          var article = artikel[index];
                          var tanggal = DateTime.parse(article['tanggal']);
                          var masuk = DateTime.parse(article['masuk']);
                          var formattedMasuk = DateFormat('HH:mm').format(masuk);
                          var pulang = article['pulang'];


                          String? formattedPulang;
                          String? totalJam;
                          if (pulang != null) {
                            var parsedPulang = DateTime.tryParse(pulang);

                            if (parsedPulang != null) {
                              formattedPulang = DateFormat('HH:mm').format(parsedPulang);
                              var durasi = parsedPulang.difference(masuk);
                              var jam = durasi.inHours;
                              var menit = durasi.inMinutes.remainder(60);
                              totalJam = '$jam jam $menit menit';
                              print('Formatted Pulang: $formattedPulang');
                            } else {
                              print('Invalid date format for pulang');
                            }
                          } else {
                            print('Pulang is null');
                          }
                          var formattedDate = DateFormat.yMMMMd('id').format(tanggal);
                          var indonesianDayOfWeek =
                          CustomIndonesianLocale.getIndonesianDayOfWeek(tanggal.weekday);

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
                              dense: true,
                              leading: ClipRRect(
                                borderRadius: BorderRadius.circular(8.0),
                                child: Text('$formattedDate \n$indonesianDayOfWeek'),
                              ),
                              title: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Masuk: $formattedMasuk', style: TextStyle(fontSize: 14.0)),
                                  Text('Pulang: ${formattedPulang ?? '-'}', style: TextStyle(fontSize: 14.0)),
                                ],
                              ),
                              subtitle: Text('Jam Kerja: $totalJam', style: TextStyle(fontSize: 14.0)),
                            ),
                          );
                        },
                      )
                          : Center(child: Text('Belum Ada Data Absensi')),
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
