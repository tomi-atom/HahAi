import "dart:convert";

import "package:hahai/main.dart";
import "package:hahai/utils/config.dart";
import "package:flutter/cupertino.dart";
import "package:flutter/material.dart";
import "package:provider/provider.dart";
import "package:shared_preferences/shared_preferences.dart";
import "package:url_launcher/url_launcher.dart";

import "../models/auth_model.dart";
import "../providers/dio_provider.dart";

class ProfilePage extends StatefulWidget {
  ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Map<String, dynamic> user = {};
  Future<void>? _launched;
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

    final _width = MediaQuery.of(context).size.width;
    final _height = MediaQuery.of(context).size.height;
    return Column(
      children: [
        Expanded(
          flex: 4,
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color:Config.primaryColor,
              image: DecorationImage(
                image: AssetImage('assets/background.gif'), // Ganti dengan path gambar latar belakang yang sesuai
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
                  'HahAI',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                  ),
                  textAlign: TextAlign.center,
                ),
                Card(
                  margin: const EdgeInsets.fromLTRB(0, 10, 0, 0),
                  child: Container(
                    width: 300,
                    height: 500,
                    child: Padding(
                      padding: const EdgeInsets.all(5),
                      child: Column(
                        children: <Widget>[
                          const Text(
                            'Developer',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          Divider(
                            color: Colors.grey[300],
                          ),
                          infoChild(_width, Icons.person, 'Tomi Firman Cahyadi'),
                          const Text(
                            'Follow Saya di',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          Config.spaceSmall,
                          ElevatedButton(
                            onPressed: () async {
                              const url = 'https://www.youtube.com/channel/UCZ7fRQvICVjF87ZiM29pyUA';
                              if(await canLaunch(url)){
                                await launch(url);
                              }else {
                                throw 'Could not launch $url';
                              }
                            },

                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.zero,
                              backgroundColor:Colors.redAccent,
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
                                  'Youtube',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Config.spaceSmall,
                          ElevatedButton(
                            onPressed: () async {
                              const url = 'https://www.instagram.com/tomifirman88/';
                              if(await canLaunch(url)){
                                await launch(url);
                              }else {
                                throw 'Could not launch $url';
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.zero,
                              backgroundColor:Colors.purple,
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
                                  'Instagram',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Config.spaceSmall,
                          ElevatedButton(
                            onPressed: () async {
                              const url = 'https://www.tiktok.com/@tomifirman88';
                              if(await canLaunch(url)){
                                await launch(url);
                              }else {
                                throw 'Could not launch $url';
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.zero,
                              backgroundColor:Colors.blueGrey,
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
                                  'Tiktok',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Config.spaceSmall,
                          ElevatedButton(
                            onPressed: () async {
                              const url = 'https://saweria.co/tomifirman';
                              if(await canLaunch(url)){
                                await launch(url);
                              }else {
                                throw 'Could not launch $url';
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.zero,
                              backgroundColor:Colors.orange,
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
                                  'SAWERIA',
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
                  ),

                ),
              ],
            ),
          ),
        ),


      ],
    );
  }

  Future<void> _launchInBrowser(Uri url) async {
    if (!await launchUrl(
      url,
      mode: LaunchMode.externalApplication,
    )) {
      throw Exception('Could not launch $url');
    }
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