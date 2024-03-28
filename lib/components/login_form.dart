import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:hahai/components/button.dart';

import 'package:hahai/main.dart';
import 'package:hahai/models/auth_model.dart';
import 'package:hahai/providers/dio_provider.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:art_sweetalert/art_sweetalert.dart';

import '../utils/config.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({Key? key}) : super(key: key);

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passController = TextEditingController();
  bool obsecurePass = true;
  bool isLoading = false;
  Future<String?> getFCMToken() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    String? fcmToken = await messaging.getToken();
    return fcmToken;
  }
  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            cursorColor:Config.primaryColor,
            decoration: const InputDecoration(
              hintText: 'NIDN / NITK',
              labelText: 'NIDN / NITK',
              alignLabelWithHint: true,
              prefixIcon: Icon(Icons.email_outlined),
              prefixIconColor:Config.primaryColor,
            ),
          ),
          Config.spaceSmall,
          TextFormField(
            controller: _passController,
            keyboardType: TextInputType.visiblePassword,
            cursorColor:Config.primaryColor,
            obscureText: obsecurePass,
            decoration: InputDecoration(
                hintText: 'Password',
                labelText: 'Password',
                alignLabelWithHint: true,
                prefixIcon: const Icon(Icons.lock_outline),
                prefixIconColor:Config.primaryColor,
                suffixIcon: IconButton(
                    onPressed: () {
                      setState(() {
                        obsecurePass = !obsecurePass;
                      });
                    },
                    icon: obsecurePass
                        ? const Icon(
                            Icons.visibility_off_outlined,
                            color: Colors.black38,
                          )
                        : const Icon(
                            Icons.visibility_outlined,
                            color:Config.primaryColor,
                          ))),
          ),
          Config.spaceSmall,
          Consumer<AuthModel>(
            builder: (context, auth, child) {
              return ElevatedButton(
                onPressed: () async {
                  if (isLoading) {
                    return; // Do nothing if the button is already in the loading state
                  }

                  setState(() {
                    isLoading = true; // Set loading state to true
                  });

                  String? fcmToken = await getFCMToken();
                  if (_emailController.text.isEmpty || _passController.text.isEmpty ) {
                    // Tampilkan notifikasi jika email atau password kosong
                    ArtSweetAlert.show(
                      context: context,
                      artDialogArgs: ArtDialogArgs(
                        type: ArtSweetAlertType.danger,
                        title: "Error",
                        text: "NIDN dan Password tidak boleh kosong.",
                      ),
                    );
                    return;
                  }
                  if (fcmToken == null ) {
                    // Tampilkan notifikasi jika email atau password kosong
                    ArtSweetAlert.show(
                      context: context,
                      artDialogArgs: ArtDialogArgs(
                        type: ArtSweetAlertType.danger,
                        title: "Error",
                        text: "FCM Token Kosong.",
                      ),
                    );
                    return;
                  }

                  try
                  {
                    // Lakukan login di sini
                    final token = await DioProvider().getToken(
                      _emailController.text,
                      _passController.text,
                      fcmToken,
                    );


                    // Cek jika token diterima dengan benar
                    if (token == true)
                    {
                      final SharedPreferences prefs = await SharedPreferences.getInstance();
                      final tokenValue = prefs.getString('token') ?? '';
                      final response = await DioProvider().getUser(tokenValue);
                      if (response != null) {
                        setState(() {
                          // JSON decode
                          final user = json.decode(response);
                          prefs.setInt('id', user['id']);
                          prefs.setString('name', user['name']);
                          prefs.setString('email', user['email']);
                          prefs.setString('user_data', jsonEncode(user));
                          auth.loginSuccess(user);
                          MyApp.navigatorKey.currentState!.pushNamed('main');
                        });
                      }


                    }else{
                      if (token.response != null) {
                        final statusCode = token.response!.statusCode!;
                        if (statusCode == 401) {
                          ArtSweetAlert.show(
                            context: context,
                            artDialogArgs: ArtDialogArgs(
                              type: ArtSweetAlertType.danger,
                              title: "Error...",
                              text: "NIDN/NITK atau Password Salah.",
                            ),
                          );
                        } else if (statusCode == 409) {
                          ArtSweetAlert.show(
                            context: context,
                            artDialogArgs: ArtDialogArgs(
                              type: ArtSweetAlertType.danger,
                              title: "Error...",
                              text: "Akun Sudah Login di Perangkat Lain.",
                            ),
                          );
                        } else {
                          ArtSweetAlert.show(
                            context: context,
                            artDialogArgs: ArtDialogArgs(
                              type: ArtSweetAlertType.danger,
                              title: "Error...",
                              text: "Terjadi Kesalahan: $statusCode",
                            ),
                          );
                        }
                      } else {
                        // Handle other DioError cases without a response
                        ArtSweetAlert.show(
                          context: context,
                          artDialogArgs: ArtDialogArgs(
                            type: ArtSweetAlertType.danger,
                            title: "Error...",
                            text: "Failed to get token. Error: ${token.message}",
                          ),
                        );
                      }
                    }
                  } catch (e) {
                    // Tangani kesalahan umum
                    print("Error:");
                    // Tampilkan notifikasi kesalahan umum
                    ArtSweetAlert.show(
                      context: context,
                      artDialogArgs: ArtDialogArgs(
                        type: ArtSweetAlertType.danger,
                        title: "Error",
                        text: e.toString(),
                      ),
                    );
                  }finally {
                    setState(() {
                      isLoading = false; // Set loading state back to false
                    });
                  }
                },
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.zero, backgroundColor:Config.primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ), // Ganti dengan warna hijau yang kamu inginkan
                ),
                child: Container(
                  constraints: BoxConstraints(maxWidth: double.infinity),
                  alignment: Alignment.center,
                  padding: EdgeInsets.symmetric(vertical: 16.0),
                  child: isLoading
                      ? CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  )
                      : Text(
                    'Masuk',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),

              );
            },
          )

        ],
      ),
    );
  }
}
