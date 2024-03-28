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
import 'map_apil.dart';

class UpdateAbsensi extends StatefulWidget {
  @override
  _UpdateAbsensiState createState() => _UpdateAbsensiState();
}


class _UpdateAbsensiState extends State<UpdateAbsensi> {
  late TextEditingController _tanggal;
  late TextEditingController _waktu;
  late TextEditingController _logbook;
  late double latitude = 0.487839;
  late double longitude = 101.411067;
  late Dio dio;
  String? imagePath;
  late LocationSettings locationSettings;
  String url = DioProvider().url;
  late StreamSubscription<Position> _positionStream;
  Map<String, dynamic> user = {};
  Map<String, dynamic> about = {};
  bool qrScannerEnabled = true;
  late String? Hasil;
  bool qrCodeValidated = false;
  @override
  void initState() {
    super.initState();
    _tanggal = TextEditingController(text: _getCurrentDate());
    _waktu = TextEditingController(text: _getCurrentTime());
    _logbook = TextEditingController();
    dio = Dio();
    _getCurrentLocation();
    fetchAbout();
  }

  void _validateQRCode(String scannedQRCode) {
    if (!qrCodeValidated) {
      List<String> qrCodeParts = scannedQRCode.split('|');

      if (qrCodeParts.length >= 3) {
        String scannedDateTime = qrCodeParts[0];
        String scannedSecretKey = qrCodeParts[1];
        String scannedUrl = qrCodeParts[2];

        // Validation based on URL and time here
        if (scannedUrl == 'www.absensi.com') {
          DateTime currentTime = DateTime.now();
          DateTime scannedTime = DateTime.parse(scannedDateTime);

          if (currentTime.difference(scannedTime).inMinutes <= 5) {
            // QR code is valid, proceed with further actions
            _showSuccessDialog('QR Code Valid');
            qrCodeValidated = true;  // Setel status ke true

          } else {
            _showErrorDialog('QR Code Tidak Sesuai - QR Code Kadaluarsa');
          }
        } else {
          _showErrorDialog('QR Code Tidak Sesuai ');//URL does not match
        }
      } else {
        _showErrorDialog('QR Code Tidak Sesuai - Incorrect format');
      }
    }
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
      if (_logbook.text.isEmpty ) {
        _showErrorDialog('Logbook Harus diisi.');
        return;
      }

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
        '$url/api/updateAbsensi',
        data: formData,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'multipart/form-data',
            'Accept': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        _showSuccessDialogInput('Data berhasil dikirim!');
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
  _showSuccessDialogInput(String message) {
    ArtSweetAlert.show(
      context: context,
      artDialogArgs: ArtDialogArgs(
        type: ArtSweetAlertType.success,
        title: "Berhasil",
        text: message,
        confirmButtonText: "OK",
      ),
    ).then((value) {
      Navigator.pop(context, "refresh");
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

  Future<void> fetchAbout() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';
    final backgroundData = await DioProvider().getAbout(token);
    if (backgroundData.containsKey('error')) {
      // Tangani jika terjadi kesalahan saat mengambil gambar latar belakang
      print('Error: ${backgroundData['error']}');
    } else {
      setState(() {
        about = Map<String, dynamic>.from(backgroundData);
      });
      print('About: ${about}');

    }
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
  Future<void> _selectDate(BuildContext context, TextEditingController controller) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (pickedDate != null && pickedDate != DateTime.now()) {
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

  Future<void> _selectDateSecurity(BuildContext context, TextEditingController controller) async {
    DateTime currentDate = DateTime.now();
    DateTime minDate = currentDate.subtract(Duration(days: 1)); // Allow selecting one day before
    DateTime maxDate = currentDate;

    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: currentDate,
      firstDate: minDate,
      lastDate: maxDate,
    );

    if (pickedDate != null) {
      setState(() {
        controller.text = DateFormat('yyyy-MM-dd').format(pickedDate);
      });
    }
  }





  @override
  Widget build(BuildContext context) {
    // Get current time
    DateTime currentTime = DateTime.now();
    // Set the time for deciding between "Masuk" and "Pulang" (e.g., 12:00 PM)
    DateTime cutoffTime = DateTime(currentTime.year, currentTime.month, currentTime.day, 12, 0, 0);

    // Determine whether it's time to show "Masuk" or "Pulang"

    bool isMasukTime = currentTime.isBefore(cutoffTime);
    bool hasSecurityRole = user['roles']?.any((role) => role['title'] == 'Security') ?? false;

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
            if (about['tipe_absen'] == "GPS")
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Lokasi Absen: $latitude - $longitude'),
                  MapWidget(latitude: latitude, longitude: longitude),
                  SizedBox(height: 20.0),
                  TextField(
                    controller: _tanggal,
                    onTap: () {
                      if (hasSecurityRole) {
                        _selectDateSecurity(context, _tanggal);
                      } else {
                        _selectDate(context, _tanggal);
                      }
                    },
                    readOnly: !hasSecurityRole, // Make it editable only if user has no security role
                    enabled: hasSecurityRole,
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
                    enabled: false,
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
                  ElevatedButton(
                    onPressed:_submitReport,
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.zero,
                      backgroundColor: Config.primaryColor,
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
              )
            else
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [

                  SizedBox(height: 20.0),
                  TextField(
                    controller: _tanggal,
                    onTap: () {
                      _selectDate(context, _tanggal);
                    },
                    readOnly: true,
                    enabled: false,
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
                    enabled: false,
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
                          onPressed: _QRViewExampleState.isQrScannerEnabled
                              ? () {
                            Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => QRViewExample(
                                onQRCodeScanned: _validateQRCode,
                              ),
                            ));
                          }
                              : null,
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.zero,
                            backgroundColor: Config.primaryColor,
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
                    onPressed: qrCodeValidated
                        ? () {
                      // Fungsi yang harus dijalankan ketika tombol ditekan setelah QR Code terverifikasi
                      _submitReport();
                    }
                        : null,
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.zero,
                      backgroundColor: qrCodeValidated
                          ? Config.primaryColor
                          : Colors.grey, // Warna abu-abu ketika tidak aktif
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
          ],

        ),
      ),
    );
  }

}

class MapWidget extends StatelessWidget {
  final double latitude;
  final double longitude;

  MapWidget({required this.latitude, required this.longitude});

  @override
  Widget build(BuildContext context) {
    return Container(
      // You can customize the size and appearance of the map container here
      height: 300.0,
      width: double.infinity,
      child: MapApil(
        initialLatitude: latitude,
        initialLongitude: longitude,
      ),  // Add your map widget here
    );
  }
}
class QRViewExample extends StatefulWidget {
  final Function(String) onQRCodeScanned;

  const QRViewExample({Key? key, required this.onQRCodeScanned}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _QRViewExampleState();
}

class _QRViewExampleState extends State<QRViewExample> {
  Barcode? result;
  QRViewController? controller;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  static bool qrScannerEnabled = true;
  static bool get isQrScannerEnabled => qrScannerEnabled; // Tambahkan getter statis


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
                  // Text('Barcode Type: ${describeEnum(result!.format)}   Data: ${result!.code}')
                    Text('')
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
                                      'Camera  ${describeEnum(snapshot.data!)}');
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
        if (result != null && result!.code != null) {
          // Call the callback function to handle QR code validation
          widget.onQRCodeScanned(result!.code!);
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
