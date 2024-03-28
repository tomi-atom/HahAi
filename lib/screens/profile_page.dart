import "dart:convert";

import "package:hahai/main.dart";
import "package:hahai/utils/config.dart";
import "package:flutter/cupertino.dart";
import "package:flutter/material.dart";
import "package:provider/provider.dart";
import "package:shared_preferences/shared_preferences.dart";

import "../models/auth_model.dart";
import "../providers/dio_provider.dart";

class ProfilePage extends StatefulWidget {
  ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Map<String, dynamic> user = {};

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
    getUserData().then((userData) {
      setState(() {
        user = userData;
      });
    });

  }

  @override
  Widget build(BuildContext context) {
    Config().init(context);
    List<dynamic> roles = user['roles'] ?? [];

    final _width = MediaQuery.of(context).size.width;
    final _height = MediaQuery.of(context).size.height;
    return Column(
      children: [
        Expanded(
          flex: 4,
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16.0),
              color:Config.primaryColor,
              image: DecorationImage(
                image: AssetImage('assets/background.png'), // Ganti dengan path gambar latar belakang yang sesuai
                fit: BoxFit.cover,
              ),
            ),
            child: Column(
              children: <Widget>[
                SizedBox(
                  height: 110,
                ),
                Image.asset( // Menampilkan gambar sebelum teks welcome
                  'assets/logo.png', // Ganti dengan path gambar yang sesuai
                  width: 100,
                  height: 100,
                  // Sesuaikan ukuran gambar dengan kebutuhan Anda
                ),
                SizedBox(
                  height: 10,
                ),
                Text(
                  'Absensi STIFAR Riau',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),

        Expanded(
          flex: 4,
          child: Container(
            color: Colors.grey[200],
            child: Center(
              child: Card(
                margin: const EdgeInsets.fromLTRB(0, 10, 0, 0),
                child: Container(
                  width: 300,
                  height: 250,
                  child: Padding(
                    padding: const EdgeInsets.all(5),
                    child: Column(
                      children: <Widget>[
                        const Text(
                          'Profile',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Divider(
                          color: Colors.grey[300],
                        ),
                        infoChild(_width, Icons.person, user['name'] ?? ''),
                        infoChild(_width, Icons.phone_android, user['email'] ?? ''),
                        infoChild(
                          _width,
                          Icons.reorder,
                          roles.isNotEmpty
                              ? ' ${roles.map((role) => role['title']).join(', ')}'
                              : '', // Ensure this is a String
                        ),

                      ],
                    ),
                  ),
                ),

              ),
            ),
          ),
        ),
      ],
    );
  }


  Widget infoChild(double width, IconData icon, data) => new Padding(
    padding: new EdgeInsets.only(bottom: 8.0),
    child: new InkWell(
      child: new Row(
        children: <Widget>[
          new SizedBox(
            width: width / 10,
          ),
          new Icon(
            icon,
            color: const Color(0xFF26CBE6),
            size: 36.0,
          ),
          new SizedBox(
            width: width / 20,
          ),
          new Text(data)
        ],
      ),
      onTap: () {
        print('Info Object selected');
      },
    ),
  );
}