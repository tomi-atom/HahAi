import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DioProvider {
  final String baseUrl = 'https://hahai.atomtekno.com';
  String get url => baseUrl;


  late SharedPreferences prefs;
  late Dio dio;

  DioProvider() {
    // Initialize DioProvider in the constructor
    initializeDio().then((_) {
      print("DioProvider initialized successfully");
    }).catchError((error) {
      print("DioProvider initialization failed: $error");
    });
  }

  Future<void> initializePreferences() async {
    prefs = await SharedPreferences.getInstance();
  }

  Future<void> initializeDio() async {
    await initializePreferences();
    dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      headers: {
        'Authorization': 'Bearer ${getTokenValue()}',
        'Accept': 'application/json',
      },
    ));
  }

  String? getTokenValue() {
    return prefs.getString('token');
  }

  void setTokenValue(String tokenValue) {
    prefs.setString('token', tokenValue);
    dio.options.headers['Authorization'] = 'Bearer $tokenValue';
  }

  Future<dynamic> getToken(String email, String password, String? fcmToken) async {
    try {
      var response = await Dio().post(
        '$baseUrl/api/login',
        data: {'email': email, 'password': password,'fcm_token': fcmToken},
        options: Options(headers: {'Accept': 'application/json'}),
      );

      if (response.statusCode == 200 && response.data != '') {
        await prefs.setString('token', response.data);
        return true;
      } else {
        return response;
      }
    } catch (error) {
      return error;
    }
  }


  Future<dynamic> getUser(String token) async {
    try {
      var response = await Dio().get(
        '$baseUrl/api/user',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200 && response.data != null) {
        return json.encode(response.data);
      } else {
        return null; // Handle the case where the response is not successful
      }
    } catch (error) {
      return 'Error: $error';
    }
  }




  // Register new user
  Future<dynamic> registerUser(
      String username, String email, String password) async {
    try {
      var user = await Dio().post(
        '$baseUrl/api/register',
        data: {'name': username, 'email': email, 'password': password},
        options: Options(
          headers: {
            'Accept': 'application/json', // Add the Accept header
          },
        ),
      );
      if (user.statusCode == 201 && user.data != '') {
        return true;
      } else {
        return false;
      }
    } catch (error) {
      return 'Error: $error';
    }
  }



  Future<dynamic> logout(String token) async {
    try {
      var response = await Dio().post(
        '$baseUrl/api/logout',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json', // Add the Accept header for consistency
          },
        ),
      );

      if (response.statusCode == 200 && response.data != '') {
        return response.statusCode;
      } else {
        return 'Error';
      }
    } catch (error) {
      return 'Error: $error';
    }
  }




  Future<dynamic> getAbsensi() async {
    try {
      Response response = await dio.get('/api/absensi');
      if (response.statusCode == 200 && response.data != '') {
        return json.encode(response.data);
      } else {
        return 'Error';
      }
    } catch (error) {
      return error;
    }
  }
  Future<dynamic> getLembur() async {
    try {
      Response response = await dio.get('/api/lembur');
      if (response.statusCode == 200 && response.data != '') {
        return json.encode(response.data);
      } else {
        return 'Error';
      }
    } catch (error) {
      return error;
    }
  }
  Future<dynamic> getApproveLembur() async {
    try {
      Response response = await dio.get('/api/approveLembur');
      if (response.statusCode == 200 && response.data != '') {
        return json.encode(response.data);
      } else {
        return 'Error';
      }
    } catch (error) {
      return error;
    }
  }
  Future<dynamic> getSakit() async {
    try {
      Response response = await dio.get('/api/sakit');
      if (response.statusCode == 200 && response.data != '') {
        return json.encode(response.data);
      } else {
        return 'Error';
      }
    } catch (error) {
      return error;
    }
  }
  Future<dynamic> getCuti() async {
    try {
      Response response = await dio.get('/api/cuti');
      if (response.statusCode == 200 && response.data != '') {
        return json.encode(response.data);
      } else {
        return 'Error';
      }
    } catch (error) {
      return error;
    }
  }
  Future<dynamic> getApproveCuti() async {
    try {
      Response response = await dio.get('/api/approveCuti');
      if (response.statusCode == 200 && response.data != '') {
        return json.encode(response.data);
      } else {
        return 'Error';
      }
    } catch (error) {
      return error;
    }
  }

  Future<dynamic> getIzin() async {
    try {
      Response response = await dio.get('/api/izin');
      if (response.statusCode == 200 && response.data != '') {
        return json.encode(response.data);
      } else {
        return 'Error';
      }
    } catch (error) {
      return error;
    }
  }
  Future<dynamic> getApproveIzin() async {
    try {
      Response response = await dio.get('/api/approveIzin');
      if (response.statusCode == 200 && response.data != '') {
        return json.encode(response.data);
      } else {
        return 'Error';
      }
    } catch (error) {
      return error;
    }
  }
  Future<dynamic> getNotifikasi() async {
    try {
      Response response = await dio.get('/api/notifikasi');
      if (response.statusCode == 200 && response.data != '') {
        return json.encode(response.data);
      } else {
        return 'Error';
      }
    } catch (error) {
      return error;
    }
  }


  Future<dynamic> cekCuti() async {
    try {
      Response response = await dio.get('/api/cekcuti');
      if (response.statusCode == 200 && response.data != '') {
        return json.encode(response.data);
      } else {
        return 'Error';
      }
    } catch (error) {
      return error;
    }
  }


  Future<dynamic> cekIzin() async {
    try {
      Response response = await dio.get('/api/cekizin');
      if (response.statusCode == 200 && response.data != '') {
        return json.encode(response.data);
      } else {
        return 'Error';
      }
    } catch (error) {
      return error;
    }
  }

  Future<dynamic> cekAbsensi() async {
    try {
      Response response = await dio.get('/api/cekabsensi');
      if (response.statusCode == 200 && response.data != '') {
        return json.encode(response.data);
      } else {
        return 'Error';
      }
    } catch (error) {
      return error;
    }
  }
  Future<dynamic> getLaporan(String token) async {
    try {
      var response = await Dio().get('$baseUrl/api/laporan');

      if (response.statusCode == 200 && response.data != '') {
        return json.encode(response.data);
      } else {
        return 'Error';
      }
    } catch (error) {
      return error;
    }
  }

  Future<dynamic> getArtikel() async {
    try {
      var response = await Dio().get('$baseUrl/api/artikel');

      if (response.statusCode == 200 && response.data != '') {
        return json.encode(response.data);
      } else {
        return 'Error';
      }
    } catch (error) {
      return error;
    }
  }

  Future<dynamic> getJamKerja() async {
    try {
      var response = await Dio().get('$baseUrl/api/jamKerja');

      if (response.statusCode == 200 && response.data != '') {
        return json.encode(response.data);
      } else {
        return 'Error';
      }
    } catch (error) {
      return error;
    }
  }
  Future<dynamic> getTipeCuti() async {
    try {
      var response = await Dio().get('$baseUrl/api/refCuti');

      if (response.statusCode == 200 && response.data != '') {
        return json.encode(response.data);
      } else {
        return 'Error';
      }
    } catch (error) {
      return error;
    }
  }

  Future<dynamic> getInfoLembur() async {
    try {
      Response response = await dio.get('/api/infoLembur');
      if (response.statusCode == 200 && response.data != '') {
        return json.encode(response.data);
      } else {
        return 'Error';
      }
    } catch (error) {
      return error;
    }
  }
  Future<dynamic> getInfoCuti() async {
    try {
      Response response = await dio.get('/api/infoCuti');
      if (response.statusCode == 200 && response.data != '') {
        return json.encode(response.data);
      } else {
        return 'Error';
      }
    } catch (error) {
      return error;
    }
  }


  Future<Map<String, dynamic>> getBackground(String token) async {
    try {
      var response = await Dio().get('$baseUrl/api/background');

      if (response.statusCode == 200 && response.data != null) {
        // Jika respons diterima dengan sukses dan data tidak kosong
        return Map<String, dynamic>.from(response.data);
      } else {
        // Jika respons tidak sesuai atau kosong
        return {'error': 'No data available'};
      }
    } catch (error) {
      // Jika terjadi kesalahan saat mengambil data
      return {'error': error.toString()};
    }
  }
  Future<Map<String, dynamic>> getAbout(String token) async {
    try {
      var response = await Dio().get('$baseUrl/api/about');

      if (response.statusCode == 200 && response.data != null) {
        // Jika respons diterima dengan sukses dan data tidak kosong
        return Map<String, dynamic>.from(response.data);
      } else {
        // Jika respons tidak sesuai atau kosong
        return {'error': 'No data available'};
      }
    } catch (error) {
      // Jika terjadi kesalahan saat mengambil data
      return {'error': error.toString()};
    }
  }



  Future<Map<String, dynamic>> getProfile(String token) async {
    try {
      var response = await Dio().get('$baseUrl/api/profile');

      if (response.statusCode == 200 && response.data != null) {
        // Jika respons diterima dengan sukses dan data tidak kosong
        return Map<String, dynamic>.from(response.data);
      } else {
        // Jika respons tidak sesuai atau kosong
        return {'error': 'No data available'};
      }
    } catch (error) {
      // Jika terjadi kesalahan saat mengambil data
      return {'error': error.toString()};
    }
  }
  Future<dynamic> getPengganti(String token) async {
    try {
      var response = await Dio().get('$baseUrl/api/pengganti');

      if (response.statusCode == 200 && response.data != '') {
        return json.encode(response.data);
      } else {
        return 'Error';
      }
    } catch (error) {
      return error;
    }
  }

  Future<dynamic> getKecamatan(String token) async {
    try {
      var response = await Dio().get('$baseUrl/api/kecamatan');

      if (response.statusCode == 200 && response.data != '') {
        return json.encode(response.data);
      } else {
        return 'Error';
      }
    } catch (error) {
      return error;
    }
  }
  Future<dynamic> getJenisRambu(String token) async {
    try {
      var response = await Dio().get('$baseUrl/api/jenisrambu');

      if (response.statusCode == 200 && response.data != '') {
        return json.encode(response.data);
      } else {
        return 'Error';
      }
    } catch (error) {
      return error;
    }
  }


}
