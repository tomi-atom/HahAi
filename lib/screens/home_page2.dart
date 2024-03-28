import 'dart:convert';
import 'package:hahai/models/auth_model.dart';
import 'package:hahai/screens/detail_artikel.dart';
import 'package:hahai/screens/page_absensi.dart';
import 'package:hahai/screens/page_cuti.dart';
import 'package:hahai/screens/page_cuti_approve.dart';
import 'package:hahai/screens/page_izin.dart';
import 'package:hahai/screens/page_izin_approve.dart';
import 'package:hahai/screens/page_izin_keluar.dart';
import 'package:hahai/screens/page_izin_keluar_approve.dart';
import 'package:hahai/screens/page_lembur.dart';
import 'package:hahai/screens/page_lembur_approve.dart';
import 'package:hahai/screens/page_sakit.dart';
import 'package:hahai/screens/update_absensi.dart';
import 'package:hahai/utils/config.dart';
import 'package:art_sweetalert/art_sweetalert.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hahai/main.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/dio_provider.dart';
import 'input_absensi.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  DioProvider dioProvider = DioProvider(); // Initialize DioProvider here
  String url = DioProvider().url;
  Map<String, dynamic> user = {};
  Map<String, dynamic> background = {};
  List<dynamic> favList = [];
  List<dynamic> absensi = [];
  List<dynamic> artikel = [];
  List<dynamic> cekabsensi = [];
  List<dynamic> cekcuti = [];
  List<dynamic> cekizin = [];
  List<Map<String, dynamic>> medCat = [
    {"icon": 'assets/icon/masuk.png', "category": "Masuk"},
    {"icon": 'assets/icon/pulang.png', "category": "Pulang"},
    {"icon": 'assets/icon/absensi.png', "category": "Kehadiran"},
    {"icon": 'assets/icon/lembur.png', "category": "Lembur"},
    {"icon": 'assets/icon/sakit.png', "category": "Sakit"},
    {"icon": 'assets/icon/cuti.png', "category": "Cuti"},
    {"icon": 'assets/icon/izin2.png', "category": "Izin Harian"},
    {"icon": 'assets/icon/izin2.png', "category": "Izin Keluar"},
    {"icon": 'assets/icon/approve.png', "category": "Approval Cuti"},
    {"icon": 'assets/icon/approve.png', "category": "Approval Lembur"},
    {"icon": 'assets/icon/izin.png', "category": "Approval Izin Harian"},
    {"icon": 'assets/icon/izin.png', "category": "Approval Izin Keluar"},
  ];
  bool isLoginChecked = false;


  Future<void> getAbsensi() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final rambu = await dioProvider.getAbsensi();
    if (rambu != 'Error') {
      setState(() {
        absensi = json.decode(rambu);
        print(absensi);
      });
    }
  }

  Future<void> getArtikel() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final data = await dioProvider.getArtikel();

    if (data != 'Error') {
      print('Cek Artikel $data');

      setState(() {
        // Decode JSON data
        artikel = json.decode(data);

        // Display only the first 3 articles
        artikel = artikel.length > 3 ? artikel.sublist(0, 3) : artikel;

        print('Cek Artikel $artikel');
      });
    }
  }


  Future<void> cekCuti() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    final dataCuti = await dioProvider.cekCuti();
    print('absensi stifar Cuti $dataCuti');

    if (dataCuti != 'Error') {
      setState(() {
        cekcuti = json.decode(dataCuti);
        print('absensi stifar Cuti $cekcuti');
      });
    }
  }

  Future<void> cekIzin() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    final data = await dioProvider.cekIzin();
    print('absensi stifar Izin $data');

    if (data != 'Error') {
      setState(() {
        cekizin = json.decode(data);
        print('absensi stifar izin $cekizin');
      });
    }
  }

  Future<void> cekAbsensi() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final rambu = await dioProvider.cekAbsensi();
    if (rambu != 'Error') {
      setState(() {
        cekabsensi = json.decode(rambu);
        print(absensi);
      });
    }
  }

  Future<Map<String, dynamic>> getUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userDataString = prefs.getString('user_data');

    if (userDataString != null) {
      return jsonDecode(userDataString);
    } else {
      return {};
    }
  }

  @override
  void initState() {
    super.initState();
    dioProvider.initializeDio();
    getAbsensi();
    cekAbsensi();
    getArtikel();
    cekCuti();
    cekIzin();
    getUserData().then((userData) {
      setState(() {
        user = userData;
      });
    });
    WidgetsBinding.instance?.addPostFrameCallback((_) {
      // Fungsi ini akan dipanggil setelah widget selesai dibangun
      Navigator.of(context).restorablePushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => HomePage()) as RestorableRouteBuilder<Object?>,
            (route) => false,
      );
    });


  }
  Future<void> _onRefresh() async {
    await getAbsensi();
    await cekAbsensi();
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
  Widget build(BuildContext context) {
    Config().init(context);

    double screenHeight = MediaQuery.of(context).size.height;
    String? name = prefs.getString('name');
    double sizedBoxHeight = screenHeight * 0.5;
    List<dynamic> roles = user['roles'] ?? [];
    bool hasSecurityRole = user['roles']?.any((role) => role['title'] == 'Security') ?? false;
    bool hasDosenRole = user['roles']?.any((role) => role['title'] == 'Dosen') ?? false;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: NetworkImage('$url/${background['gambar']}'),
            fit: BoxFit.cover,
          ),
        ),
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
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name ?? '',
                            style: const TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          roles.isNotEmpty
                              ? Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              ' ${roles.map((role) => role['title']).join(', ')}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.blue,
                              ),
                            ),
                          )
                              : Container(),
                        ],
                      ),
                      Container(
                        decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                              color: Colors.blue.withOpacity(0.5),
                              spreadRadius: 2,
                              blurRadius: 5,
                              offset: const Offset(0, 2),
                            ),
                          ],
                          shape: BoxShape.circle,
                        ),
                        child: CircleAvatar(
                          radius: 30,
                          backgroundColor: Colors.white,
                          backgroundImage: AssetImage('assets/logo.png'),
                        ),
                      ),
                    ],
                  ),
                  Config.spaceMedium,
                  CarouselSlider(
                    options: CarouselOptions(
                      height: 200.0,
                      autoPlay: true,
                      enlargeCenterPage: true,
                      aspectRatio: 16 / 9,
                      autoPlayCurve: Curves.fastOutSlowIn,
                      enableInfiniteScroll: true,
                      autoPlayAnimationDuration: Duration(milliseconds: 800),
                      viewportFraction: 0.8,
                    ),
                    items: artikel.isEmpty
                        ? [
                      Builder(
                        builder: (BuildContext context) {
                          return Container(
                            width: MediaQuery.of(context).size.width,
                            margin: EdgeInsets.symmetric(horizontal: 5.0),
                            decoration: BoxDecoration(
                              color:Config.primaryColor,
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            child: Center(
                              child: Text(
                                'Selamat Datang',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ]
                        : artikel.map((article) {
                      return Builder(
                        builder: (BuildContext context) {
                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      DetailArtikel(artikelData: article),
                                ),
                              );
                            },
                            child: Container(
                              width: MediaQuery.of(context).size.width,
                              margin: EdgeInsets.symmetric(horizontal: 5.0),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8.0),
                                image: DecorationImage(
                                  image: NetworkImage(
                                      '${DioProvider().url}/${article['gambar']}'),
                                  fit: BoxFit.cover,
                                ),
                              ),

                            ),
                          );
                        },
                      );
                    }).toList(),
                  ),
                  Config.spaceMedium,
                  SizedBox(
                    height: sizedBoxHeight,
                    child: GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 4,
                        crossAxisSpacing: 10.0,
                        mainAxisSpacing: 10.0,
                      ),
                      itemCount: medCat.length,
                      itemBuilder: (context, index) {
                        if ((medCat[index]['category'] == 'Approval Cuti' ||
                            medCat[index]['category'] == 'Approval Lembur') &&
                            cekcuti.isEmpty) {
                          return Container();
                        }

                        if ((medCat[index]['category'] == 'Approval Izin Harian' ||
                            medCat[index]['category'] == 'Approval Izin Keluar') &&
                            cekizin.isEmpty) {
                          return Container();
                        }
                        if ((medCat[index]['category'] == 'Izin Keluar') &&
                            !hasDosenRole) {
                          return Container();
                        }

                        return GestureDetector(
                          onTap: ()async {
                            var currentDate = DateTime.now();
                            if (medCat[index]['category'] == 'Masuk') {
                              if (cekabsensi.isNotEmpty) {
                                var article = cekabsensi.first;
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
                                  String refresh = await Navigator.push(context, MaterialPageRoute(builder: (context)=> InputAbsensi()));

                                  if(refresh == "refresh"){
                                    await _onRefresh();
                                  }
                                }
                              } else {
                                String refresh = await Navigator.push(context, MaterialPageRoute(builder: (context)=> InputAbsensi()));

                                if(refresh == "refresh"){
                                  await _onRefresh();
                                }
                              }
                            } else if (medCat[index]['category'] == 'Pulang') {
                              if (cekabsensi.isNotEmpty) {
                                var article = cekabsensi.first;
                                var tanggal = DateTime.parse(article['tanggal']);
                                var pulang = article['pulang'];
                                if (tanggal.day == currentDate.day &&
                                    tanggal.month == currentDate.month &&
                                    tanggal.year == currentDate.year) {
                                  if (pulang == null) {
                                    String refresh = await Navigator.push(context, MaterialPageRoute(builder: (context)=> UpdateAbsensi()));

                                    if(refresh == "refresh"){
                                      await _onRefresh();
                                    }
                                  } else {
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
                            } else if (medCat[index]['category'] == 'Kehadiran') {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => PageAbsensi()),
                              );
                            } else if (medCat[index]['category'] == 'Lembur') {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => PageLembur()),
                              );
                            } else if (medCat[index]['category'] == 'Sakit') {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => PageSakit()),
                              );
                            } else if (medCat[index]['category'] == 'Cuti') {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => PageCuti()),
                              );
                            } else if (medCat[index]['category'] == 'Izin Harian') {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => PageIzin()),
                              );
                            } else if (medCat[index]['category'] == 'Izin Keluar') {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => PageIzinKeluar()),
                              );
                            }
                            else if (medCat[index]['category'] == 'Approval Cuti') {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => PageCutiApprove()),
                              );
                            }
                            else if (medCat[index]['category'] == 'Approval Lembur') {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => PageLemburApprove()),
                              );
                            }
                            else if (medCat[index]['category'] == 'Approval Izin Harian') {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => PageIzinApprove()),
                              );
                            }
                            else if (medCat[index]['category'] == 'Approval Izin Keluar') {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => PageIzinKeluarApprove()),
                              );
                            }
                          },
                          child: Column(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(15),
                                child: Card(
                                  elevation: 4,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.blue,
                                          spreadRadius: 3,
                                          blurRadius: 8,
                                          offset: Offset(0, 4),
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
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              Text(
                                medCat[index]['category'],
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.black,
                                ),
                              ),
                            ],
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
      ),
    );
  }
}
