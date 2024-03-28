import 'dart:convert';

import 'package:hahai/models/auth_model.dart';
import 'package:hahai/screens/input_absensi.dart';
import 'package:hahai/screens/input_lembur.dart';
import 'package:hahai/screens/laporan_details.dart';
import 'package:hahai/screens/update_absensi.dart';
import 'package:hahai/utils/config.dart';
import 'package:art_sweetalert/art_sweetalert.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/date_symbol_data_local.dart';
import '../main.dart';
import '../providers/dio_provider.dart';

class HomeAbsen extends StatefulWidget {
  const HomeAbsen({Key? key}) : super(key: key);

  @override
  State<HomeAbsen> createState() => _HomeAbsenState();
}

//enum for rambu kondisi
class _HomeAbsenState extends State<HomeAbsen> {

  String url = DioProvider().url;

  Map<String, dynamic> user = {};
  List<dynamic> favList = [];

  List<dynamic> artikel = [];
  List<Map<String, dynamic>> medCat = [
    {
      "icon": 'assets/icon/absensi.png',
      "category": "Absensi Masuk",
    },
    {
      "icon":'assets/icon/absensi.png',
      "category": "Absensi Pulang",
    },
  ];
  Future<void> _onRefresh() async {
    await getAbsensi();

    setState(() {});
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

  //get artikel details
  Future<void> getAbsensi() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final rambu = await DioProvider().getAbsensi();
    if (rambu != 'Error') {
      setState(() {
        artikel = json.decode(rambu);
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
    double screenHeight = MediaQuery.of(context).size.height;

    double sizedBoxHeight = screenHeight * 0.6;

    return RefreshIndicator(
      onRefresh: _onRefresh,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 15,
            vertical: 15,
          ),
          child: SafeArea(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(
                        user['name'] ?? '',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(
                        child: CircleAvatar(
                          radius: 30,
                          backgroundImage:
                          AssetImage('assets/logo.png'),
                        ),
                      )
                    ],
                  ),
                  Config.spaceMedium,

                  // Tambahkan widget kondisional untuk menampilkan pesan "Anda Belum Absen Hari Ini"
                  artikel.isNotEmpty
                      ?  ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: artikel.length,
                    itemBuilder: (context, index) {
                      var article = artikel[index];
                      var tanggal = DateTime.parse(article['tanggal']);

                      if (tanggal.day == DateTime.now().day &&
                          tanggal.month == DateTime.now().month &&
                          tanggal.year == DateTime.now().year) {
                        var masuk = DateTime.parse(article['masuk']);
                        var formattedMasuk = DateFormat('HH:mm').format(masuk);
                        var pulang = article['pulang'];

                        String? formattedPulang;

                        if (pulang != null) {
                          var parsedPulang = DateTime.tryParse(pulang);

                          if (parsedPulang != null) {
                            formattedPulang = DateFormat('HH:mm').format(parsedPulang);
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
                              child: Text('$formattedDate \n $indonesianDayOfWeek'),
                            ),
                            subtitle: Text('Masuk: $formattedMasuk \nPulang: ${formattedPulang ?? '-'}'),

                          ),
                        );
                      } else {
                        return Container();
                      }
                    },
                  )
                      : Center(child: Text('Anda Belum Absen Hari ini')),
                  Config.spaceMedium,

                  SizedBox(
                    height: sizedBoxHeight,
                    child: GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 10.0,
                        mainAxisSpacing: 10.0,
                      ),
                      itemCount: medCat.length,
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          onTap: () {
                            var currentDate = DateTime.now();
                            if (medCat[index]['category'] == 'Absensi Masuk') {
                              if (artikel.isNotEmpty) {
                                var article = artikel.first; // Choose the appropriate logic to get the desired date
                                var tanggal = DateTime.parse(article['tanggal']);

                                if (tanggal.day == currentDate.day &&
                                    tanggal.month == currentDate.month &&
                                    tanggal.year == currentDate.year) {
                                  ArtSweetAlert.show(
                                    context: context,
                                    artDialogArgs: ArtDialogArgs(
                                      type: ArtSweetAlertType.warning,
                                      title: "Warning",
                                      text: "Anda Sudah Absen Masuk.",
                                    ),
                                  );
                                } else {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => InputAbsensi()),
                                  );

                                }
                              } else {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => InputAbsensi()),
                                );

                              }
                            } else if (medCat[index]['category'] == 'Absensi Pulang') {
                              if (artikel.isNotEmpty) {
                                var article = artikel.first; // Choose the appropriate logic to get the desired date
                                var tanggal = DateTime.parse(article['tanggal']);
                                var pulang = article['pulang'];
                                if (tanggal.day == currentDate.day &&
                                    tanggal.month == currentDate.month &&
                                    tanggal.year == currentDate.year) {
                                  if (pulang == null) {
                                    // If 'pulang' is null, navigate to UpdateAbsensi
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (context) => UpdateAbsensi()),
                                    );
                                  } else {
                                    // If 'pulang' is not null, show an error message using ArtSweetAlert
                                    ArtSweetAlert.show(
                                      context: context,
                                      artDialogArgs: ArtDialogArgs(
                                        type: ArtSweetAlertType.warning,
                                        title: "Warning",
                                        text: "Anda sudah melakukan Absen Pulang.",
                                      ),
                                    );
                                  }
                                } else {
                                  ArtSweetAlert.show(
                                    context: context,
                                    artDialogArgs: ArtDialogArgs(
                                      type: ArtSweetAlertType.warning,
                                      title: "Warning",
                                      text: "Anda Belum Absen Masuk.",
                                    ),
                                  );


                                }
                              } else {
                                ArtSweetAlert.show(
                                  context: context,
                                  artDialogArgs: ArtDialogArgs(
                                    type: ArtSweetAlertType.warning,
                                    title: "Warning",
                                    text: "Anda Belum Absen Masuk.",
                                  ),
                                );

                              }
                            }
                          },
                          child: Card(
                            elevation: 3,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5),
                                boxShadow: [
                                  BoxShadow(
                                    color:Config.primaryColor.withOpacity(0.35), // Shadow color and opacity
                                    spreadRadius: 2, // How much the shadow should spread
                                    blurRadius: 4, // How blurry the shadow should be
                                    offset: Offset(0, 3), // Shadow position
                                  ),
                                ],
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Image.asset(
                                    medCat[index]['icon'],
                                    width: 40,
                                    height: 40,
                                  ),
                                  SizedBox(height: 10),
                                  Text(
                                    medCat[index]['category'],
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                ],
              ),
            ),
          ),
        ),

    );
  }
}
