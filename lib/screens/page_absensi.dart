import 'dart:convert';

import 'package:hahai/utils/config.dart';
import 'package:art_sweetalert/art_sweetalert.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../main.dart';
import '../providers/dio_provider.dart';

class PageAbsensi extends StatefulWidget {
  const PageAbsensi({Key? key}) : super(key: key);

  @override
  State<PageAbsensi> createState() => _PageAbsensiState();
}

//enum for rambu kondisi
class _PageAbsensiState extends State<PageAbsensi> {

  DioProvider dioProvider = DioProvider(); // Initialize DioProvider once
  Map<String, dynamic> user = {};
  List<dynamic> favList = [];
  int selectedMonth = DateTime.now().month;
  int selectedYear = DateTime.now().year;
  List<dynamic> artikel = [];
  List<dynamic> refJamKerja = [];
  int totalKehadiran = 0; // Total kehadiran per bulan
  int totalJamKerjaPerMinggu = 0; // Total jam kerja per minggu
  int totalMenitKerjaPerMinggu = 0; // Total jam kerja per minggu
  int totalJamKerjaPerBulan = 0;
  int totalMenitKerjaPerBulan = 0;
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
  Future<void> _onRefresh2() async {
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
  Future<void> getJamKerja() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';
    final dataJam = await DioProvider().getJamKerja();
    if (dataJam != 'Error') {
      setState(() {
        refJamKerja = json.decode(dataJam);
        print(refJamKerja);
      });
    }
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
        totalKehadiran = hitungKehadiranPerBulan(artikel);
        totalJamKerjaPerMinggu = hitungJamKerjaPerMinggu(artikel);
        totalJamKerjaPerBulan = hitungJamKerjaPerBulan(artikel);
      });
    }
  }
  int hitungKehadiranPerBulan(List<dynamic> data) {
    int jumlahKehadiran = 0;
    for (var item in data) {
      if (item['masuk'] != null) {
        jumlahKehadiran++;
      }
    }
    return jumlahKehadiran;
  }
  int hitungJamKerjaPerMinggu(List<dynamic> data) {
    int totalJamKerja = 0;
    int totalMenitKerja = 0;

    // Get the start and end dates of the current week
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));

    // Exclude hours worked on Monday, Tuesday, and Wednesday of the current week
    final excludedStart = DateTime.now().subtract(Duration(days: (now.weekday > 4) ? now.weekday - 4 : 7 + now.weekday - 4));

    for (var item in data) {
      if (item['masuk'] != null && item['pulang'] != null) {
        var masuk = DateTime.parse(item['masuk']);

        // Exclude hours worked before Thursday of the current week
        if (masuk.isAfter(excludedStart)) {
          var pulang = DateTime.parse(item['pulang']!);

          // Check if the working hours are within the current week
          if (masuk.isAfter(startOfWeek) && pulang.isBefore(startOfWeek.add(Duration(days: 7)))) {
            var durasiSaatKehadiran =
                DateTime(masuk.year, masuk.month, masuk.day, pulang.hour, pulang.minute)
                    .difference(
                  DateTime(masuk.year, masuk.month, masuk.day, masuk.hour, masuk.minute),
                )
                    .inMinutes;
            totalJamKerja += durasiSaatKehadiran ~/ 60;
            totalMenitKerja+= durasiSaatKehadiran % 60;
          }
        }
      }
    }

    return totalJamKerja * 60 + totalMenitKerja;
  }
  int hitungJamKerjaPerBulan(List<dynamic> data) {
    int totalMenitKerja = 0;

    for (var item in data) {
      if (item['masuk'] != null && item['pulang'] != null) {
        var masuk = DateTime.parse(item['masuk']);
        var pulang = DateTime.parse(item['pulang']!);
        var durasi = pulang.difference(masuk);
        totalMenitKerja += durasi.inHours * 60; // Konversi jam ke menit
        totalMenitKerja += durasi.inMinutes; // Tambahkan menit
      }
    }

    return totalMenitKerja;
  }
  String formatMenitKeJamMenit(int menit) {
    final jam = menit ~/ 60;
    final menitSisa = menit % 60;
    return '${jam} jam ${menitSisa} menit';
  }


  String generateMonthlyReport(int month, int year) {
    var filteredArtikel = artikel
        .where((data) =>
    DateTime.parse(data['tanggal']).month == month &&
        DateTime.parse(data['tanggal']).year == year)
        .toList();

    if (filteredArtikel.isEmpty) {
      return 'Tidak ada data absensi bulan ini.';
    }

    String report =
        'ABSENSI BULAN ${DateFormat('MMMM y', 'id').format(DateTime(year, month))}\n';

    // Find the first Monday of the month
    DateTime firstDayOfMonth = DateTime(year, month, 1);
    int startDayOfWeek = 1; // Start from Monday
    while (firstDayOfMonth.weekday != startDayOfWeek) {
      firstDayOfMonth = firstDayOfMonth.subtract(Duration(days: 1));
    }

    // Find the last day of the previous month
    DateTime lastDayOfPreviousMonth = firstDayOfMonth.subtract(Duration(days: 1));

    // Find the last day of the month
    DateTime lastDayOfMonth = DateTime(year, month + 1, 0);

    // Loop through weeks
    while (firstDayOfMonth.isBefore(lastDayOfMonth) ||
        firstDayOfMonth.isAtSameMomentAs(lastDayOfMonth)) {
      int endDayOfWeek = firstDayOfMonth
          .add(Duration(days: 6))
          .isAfter(lastDayOfMonth) ? lastDayOfMonth.day : firstDayOfMonth.add(Duration(days: 6)).day;

      if (firstDayOfMonth.month != month) {
        // If the current week belongs to the previous month, adjust the days
        endDayOfWeek = lastDayOfPreviousMonth.day;
      }

      int totalJamKerja = 0;
      int totalMenitKerja = 0;

      for (int day = firstDayOfMonth.day; day <= endDayOfWeek; day++) {
        var filteredByDate = filteredArtikel
            .where((data) => DateTime.parse(data['tanggal']).day == day)
            .toList();

        if (filteredByDate.isNotEmpty && filteredByDate[0]['pulang'] != null) {
          var masuk = DateTime.parse(filteredByDate[0]['masuk']);
          var pulang = DateTime.parse(filteredByDate[0]['pulang']);

          var durasi = pulang.difference(masuk);
          totalJamKerja += durasi.inHours;
          totalMenitKerja += durasi.inMinutes.remainder(60);
        }
      }

      int totalMinutes = totalJamKerja * 60 + totalMenitKerja;
      int hours = totalMinutes ~/ 60;
      int minutes = totalMinutes % 60;

      report +=
      'MINGGU (${DateFormat('dd MMMM y', 'id').format(firstDayOfMonth)} - ${DateFormat('dd MMMM y', 'id').format(firstDayOfMonth.add(Duration(days: 6)))}): ${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')} JAM\n\n';

      firstDayOfMonth = firstDayOfMonth.add(Duration(days: 7));
    }

    return report;
  }


  String formatTime(int totalJam, int totalMenit) {
    final int jam = totalJam + (totalMenit / 60).round();
    final int menit = (totalMenit % 60).round();
    return '$jam jam $menit menit';
  }

  String formatJadwal(DateTime? masuk, DateTime? pulang) {
    final String masukTime = masuk != null ? DateFormat('HH:mm').format(masuk) : '-';
    final String pulangTime = pulang != null ? DateFormat('HH:mm').format(pulang) : '-';
    return "$masukTime - $pulangTime";
  }

  @override
  void initState() {
    getAbsensi(selectedMonth, selectedYear);
    getJamKerja();
    super.initState();

  }
  @override
  Widget build(BuildContext context) {
    Config().init(context);


    return Scaffold(
      appBar: AppBar(
        title: Text('Kehadiran'),
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
                  SizedBox(height: 10),
                  Text(
                    'Total Kehadiran: $totalKehadiran', // Tampilkan total kehadiran per bulan
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Row(
                    children: [
                      Text(
                        'Total Jam Kerja: ${formatTime(totalJamKerjaPerMinggu ~/ 60, totalJamKerjaPerMinggu % 60)}',
                        style: TextStyle(fontSize: 14),
                      ),
                      TextButton(
                        onPressed: () => showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text('Detail Perminggu'),
                              content: Text(generateMonthlyReport(selectedMonth, selectedYear)),
                              actions: <Widget>[
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: Text('TUTUP'),
                                ),
                              ],
                            );
                          },
                        ),
                        child: Text('Detail'),
                      ),
                    ],
                  ),




                  SizedBox(height: 10),
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

                        final DateTime batasMasuk = DateTime(masuk.year, masuk.month, masuk.day, 8, 0).add(Duration(hours: 7)); // Batas masuk jam 8 pagi ditambah 7 jam

                        String teksTerlambat = '';
                        String teksPulangCepat = '';

                        if (masuk.isAfter(batasMasuk)) {
                          // Hitung selisih waktu antara waktu masuk yang sebenarnya dan waktu masuk yang seharusnya
                          final Duration selisihMasuk = masuk.difference(batasMasuk);

                          // Ambil nilai jam dan menit dari selisih waktu
                          final int jamTerlambat = selisihMasuk.inHours;
                          final int menitTerlambat = selisihMasuk.inMinutes.remainder(60);

                          // Format keterlambatan
                          teksTerlambat = 'Terlambat: $jamTerlambat jam $menitTerlambat menit';
                        }


                        if (formattedPulang != null) {
                          // Asumsi variabel pulang sudah di-parse ke DateTime sebelumnya
                          final DateTime parsedPulang = DateTime.parse(pulang);
                          final DateTime batasPulang = DateTime(parsedPulang.year, parsedPulang.month, parsedPulang.day, 15, 30).add(Duration(hours: 7));

                          if (parsedPulang.isBefore(batasPulang)) {
                            final int menitPulangCepat = batasPulang.difference(parsedPulang).inMinutes;
                            final String pulangCepatFormatted = formatMenitKeJamMenit(menitPulangCepat);
                            teksPulangCepat = 'Cepat: $pulangCepatFormatted';
                          }
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
                            dense: true,
                            leading: ClipRRect(
                              borderRadius: BorderRadius.circular(8.0),
                              child: Text('$formattedDate \n$indonesianDayOfWeek'),
                            ),
                            title: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  RichText(
                                    text: TextSpan(
                                      children: [
                                        TextSpan(
                                          text: 'Masuk: $formattedMasuk ',
                                          style: TextStyle(fontSize: 10.0, color: Colors.black), // Warna default teks
                                        ),
                                        if (teksTerlambat.isNotEmpty)
                                          TextSpan(
                                            text: '($teksTerlambat)',
                                            style: TextStyle(fontSize: 10.0, color: Colors.red), // Teks terlambat menjadi merah
                                          ),
                                      ],
                                    ),
                                  ),
                                  RichText(
                                    text: TextSpan(
                                      children: [
                                        TextSpan(
                                          text: 'Pulang: ${formattedPulang ?? '-'} ',
                                          style: TextStyle(fontSize: 10.0, color: Colors.black), // Warna default teks
                                        ),
                                        if (teksPulangCepat.isNotEmpty)
                                          TextSpan(
                                            text: '($teksPulangCepat)',
                                            style: TextStyle(fontSize: 10.0, color: Colors.red), // Teks pulang cepat menjadi merah
                                          ),
                                      ],
                                    ),
                                  ),
                                ]

                            ),
                            subtitle: Text(
                              'Jam Kerja: ${totalJam ?? '-'}',
                              style: TextStyle(fontSize: 12.0),
                            ),

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
