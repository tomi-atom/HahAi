import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:art_sweetalert/art_sweetalert.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/auth_model.dart';
import '../providers/dio_provider.dart';
import '../utils/config.dart';

class UpdateAbsensi2 extends StatefulWidget {
  @override
  _UpdateAbsensi2State createState() => _UpdateAbsensi2State();
}
class Kecamatan {
  final String id;
  final String namaKecamatan;

  Kecamatan(this.id, this.namaKecamatan);
}




class _UpdateAbsensi2State extends State<UpdateAbsensi2> {
  late TextEditingController _tanggal;
  late TextEditingController _waktu;
  late TextEditingController _logbook;
  late double latitude = 0.0;
  late double longitude = 0.0;
  late Dio dio;
  String? imagePath;
  late LocationSettings locationSettings;
  String url = DioProvider().url;
  late StreamSubscription<Position> _positionStream;
  Map<String, dynamic> user = {};

  late List<Kecamatan> kecamatanOptions = [];
  bool qrScannerPulang = true;
  late String? Hasil;
  @override
  void initState() {
    super.initState();
    _tanggal = TextEditingController(text: _getCurrentDate());
    _waktu = TextEditingController(text: _getCurrentTime());
    _logbook = TextEditingController();
    dio = Dio();
    _getCurrentLocation();
  }



  _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return;
    }
    Timer.periodic(Duration(seconds: 1), (Timer timer) async {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.best);
      setState(() {
        latitude = position.latitude;
        longitude = position.longitude;
      });
    });
    // _positionStream = Geolocator.getPositionStream(locationSettings: locationSettings// in meters
    // ).listen((Position position) {
    //   setState(() {
    //     latitude = position.latitude;
    //     longitude = position.longitude;
    //   });
    // });
  }

  _imgCmr() async {
    final XFile? image = await ImagePicker().pickImage(source: ImageSource.camera);
    setState(() {
      imagePath = image?.path;
    });
    debugPrint('path: ${image?.path}');
  }
  _imgGalery() async {
    final XFile? image = await ImagePicker().pickImage(source: ImageSource.gallery);
    setState(() {
      imagePath = image?.path;
    });
    debugPrint('path: ${image?.path}');
  }
  _submitReport() async {
    try {
      // if (imagePath == null) {
      //   _showErrorDialog('Harap Scan  QR Code terlebih dahulu.');
      //   return;
      // }

      FormData formData = FormData.fromMap({
        'image': imagePath != null ? await MultipartFile.fromFile(imagePath!) : null,
        'latitude': latitude.toString(),
        'longitude': longitude.toString(),
        'tanggal': _tanggal.text,
        'pulang': _waktu.text,
        'logbook': _logbook.text,
      });


      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';

      final response = await Dio().post(
        '$url/api/UpdateAbsensi2',
        data: formData,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'multipart/form-data',
          },
        ),
      );

      if (response.statusCode == 200) {
        _showSuccessDialog('Data berhasil dikirim!');
      } else {
        _showErrorDialog('Gagal mengirim data. ${response.data['message']}');
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

  _updatePosition() async {
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.best,
    );
    setState(() {
      latitude = position.latitude;
      longitude = position.longitude;
    });
  }



  @override
  void dispose() {
    _positionStream.cancel();
    super.dispose();
  }

  String _getCurrentDate() {
    return DateFormat('y-MM-dd').format(DateTime.now());
  }
  String _getCurrentTime() {
    return  DateFormat('HH:mm').format(DateTime.now());
  }
  Future<void> _selectDate(BuildContext context, TextEditingController controller, {bool isSecurity = false}) async {
    DateTime currentDate = DateTime.now();
    DateTime firstAllowedDate = isSecurity ? currentDate.subtract(Duration(days: 1)) : DateTime(2000);

    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: currentDate,
      firstDate: firstAllowedDate,
      lastDate: currentDate,
    );

    if (pickedDate != null) {
      setState(() {
        controller.text = DateFormat('yyyy-MM-dd').format(pickedDate);
      });
    }
  }
  Future<void> _selectTime(BuildContext context, TextEditingController controller) async {
    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (pickedTime != null) {
      DateTime selectedTime = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day,
          pickedTime.hour, pickedTime.minute);
      setState(() {
        controller.text = DateFormat('HH:mm').format(selectedTime);
      });
    }
  }




  @override
  Widget build(BuildContext context) {
    // Get current time
    DateTime currentTime = DateTime.now();
    // Set the time for deciding between "Pulang" and "Pulang" (e.g., 12:00 PM)
    DateTime cutoffTime = DateTime(currentTime.year, currentTime.month, currentTime.day, 12, 0, 0);

    // Determine whether it's time to show "Pulang" or "Pulang"

    bool isPulangTime = currentTime.isBefore(cutoffTime);

    return Scaffold(
      appBar: AppBar(
        title: Text('Absensi Pulang'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Text('Lokasi Absen: $latitude - $longitude'),
            SizedBox(height: 20.0),

            TextField(
              controller: _tanggal,
              onTap: () {
                _selectDate(context, _tanggal, isSecurity: true);
              },
              readOnly: true,
              enabled: false, // Menonaktifkan editing
              decoration: InputDecoration(
                labelText: 'Tanggal',
                border: OutlineInputBorder(),
              ),
              maxLines: 1,
            ),
            SizedBox(height: 20.0),
            TextField(
              controller: _waktu,
              onTap: () {
                _selectTime(context, _waktu);
              },
              readOnly: true,
              enabled: false, // Menonaktifkan editing
              decoration: InputDecoration(
                labelText: 'Jam Pulang',
                border: OutlineInputBorder(),
              ),
              maxLines: 1,
            ),
            SizedBox(height: 20.0),
            TextField(
              controller: _logbook,
              decoration: InputDecoration(
                labelText: 'Logbook Kegiatan Hari Ini',
                border: OutlineInputBorder(),
              ),
              maxLines: 6,
            ),
            SizedBox(height: 10.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _QRViewExampleState.isQrScannerPulang ? () {
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => const QRViewExample(),
                      ));
                    } : null,
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.zero,
                      backgroundColor:Config.primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                    child: Ink(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: Container(
                        alignment: Alignment.center,
                        padding: EdgeInsets.symmetric(vertical: 16.0),
                        child: Text(
                          'Scan QR Code',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: 25.0),
            ElevatedButton(
              onPressed: _QRViewExampleState.isQrScannerPulang
                  ? null // Tidak ada aksi jika qrScannerPulang false
                  : _submitReport, // Panggil _submitReport jika qrScannerPulang true
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.zero,
                backgroundColor:Config.primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
              child: Ink(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: Container(
                  constraints: BoxConstraints(maxWidth: double.infinity),
                  alignment: Alignment.center,
                  padding: EdgeInsets.symmetric(vertical: 16.0),
                  child: Text(
                    'Simpan Absen Pulang',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),

          ],
        ),
      ),
    );
  }

}


class QRViewExample extends StatefulWidget {
  const QRViewExample({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _QRViewExampleState();
}

class _QRViewExampleState extends State<QRViewExample> {
  Barcode? result;
  QRViewController? controller;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  static bool qrScannerPulang = true;
  static bool get isQrScannerPulang => qrScannerPulang; // Tambahkan getter statis


  // In order to get hot reload to work we need to pause the camera if the platform
  // is android, or resume the camera if the platform is iOS.
  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller!.pauseCamera();
    }
    controller!.resumeCamera();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[
          Expanded(flex: 4, child: _buildQrView(context)),
          Expanded(
            flex: 1,
            child: FittedBox(
              fit: BoxFit.contain,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  if (result != null)
                    Text(
                        'Barcode Type: ${describeEnum(result!.format)}   Data: ${result!.code}')
                  else
                    const Text('Scan a code'),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Container(
                        margin: const EdgeInsets.all(8),
                        child: ElevatedButton(
                            onPressed: () async {
                              await controller?.toggleFlash();
                              setState(() {});
                            },
                            child: FutureBuilder(
                              future: controller?.getFlashStatus(),
                              builder: (context, snapshot) {
                                return Text('Flash: ${snapshot.data}');
                              },
                            )),
                      ),
                      Container(
                        margin: const EdgeInsets.all(8),
                        child: ElevatedButton(
                            onPressed: () async {
                              await controller?.flipCamera();
                              setState(() {});
                            },
                            child: FutureBuilder(
                              future: controller?.getCameraInfo(),
                              builder: (context, snapshot) {
                                if (snapshot.data != null) {
                                  return Text(
                                      'Camera facing ${describeEnum(snapshot.data!)}');
                                } else {
                                  return const Text('loading');
                                }
                              },
                            )),
                      )
                    ],
                  ),

                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildQrView(BuildContext context) {
    // For this example we check how width or tall the device is and change the scanArea and overlay accordingly.
    var scanArea = (MediaQuery.of(context).size.width < 400 ||
        MediaQuery.of(context).size.height < 400)
        ? 150.0
        : 300.0;
    // To ensure the Scanner view is properly sizes after rotation
    // we need to listen for Flutter SizeChanged notification and update controller
    return QRView(
      key: qrKey,
      onQRViewCreated: _onQRViewCreated,
      overlay: QrScannerOverlayShape(
          borderColor: Colors.red,
          borderRadius: 10,
          borderLength: 30,
          borderWidth: 10,
          cutOutSize: scanArea),
      onPermissionSet: (ctrl, p) => _onPermissionSet(context, ctrl, p),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    setState(() {
      this.controller = controller;
    });
    controller.scannedDataStream.listen((scanData) {
      setState(() {
        result = scanData;
        if (result != null) {
          Navigator.pop(context);
          qrScannerPulang = false;
        }
      });
    });
  }

  void _onPermissionSet(BuildContext context, QRViewController ctrl, bool p) {
    log('${DateTime.now().toIso8601String()}_onPermissionSet $p');
    if (!p) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('no Permission')),
      );
    }
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}
