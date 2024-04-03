import 'dart:convert';

import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:hahai/main_layout.dart';
import 'package:hahai/models/auth_model.dart';
import 'package:hahai/providers/dio_provider.dart';
import 'package:hahai/screens/auth_page.dart';
import 'package:hahai/screens/home_page.dart';
import 'package:hahai/utils/config.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'firebase_options.dart';
import 'model/push_notification.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
late SharedPreferences prefs;


Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print("Handling a background message: ${message.messageId}");
}


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // await Firebase.initializeApp(
  //   options: DefaultFirebaseOptions.currentPlatform,
  // );
  prefs = await SharedPreferences.getInstance();

  await dotenv.load(fileName: "assets/config/.env");
  await CustomIndonesianLocale.initialize();
  tz.initializeTimeZones();
  tz.setLocalLocation(tz.getLocation('Asia/Jakarta'));

  // Initialize DioProvider or any other setup you need
  DioProvider dioProvider = DioProvider();
  await dioProvider.initializeDio();
  MobileAds.instance.initialize();
  runApp(
    ChangeNotifierProvider<AuthModel>(
      create: (context) => AuthModel(),
      child: const MyApp(),
    ),
  );
}


class CustomIndonesianLocale {
  static Future<void> initialize() async {
    await initializeDateFormatting('id', null);
  }

  static String getIndonesianDayOfWeek(int dayOfWeek) {
    switch (dayOfWeek) {
      case 1:
        return 'Senin';
      case 2:
        return 'Selasa';
      case 3:
        return 'Rabu';
      case 4:
        return 'Kamis';
      case 5:
        return 'Jumat';
      case 6:
        return 'Sabtu';
      case 7:
        return 'Minggu';
      default:
        return '';
    }
  }
}
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  //this is for push navigator
  static final navigatorKey = GlobalKey<NavigatorState>();
  static const String ACCESS_TOKEN = 'sk.eyJ1IjoidG9taWF0b20iLCJhIjoiY2xwcnE1eHFwMGRsaTJscndkdjhpZWJlaSJ9.zvS4K8K357irZEDDA-3vqg';
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<AuthModel>(
      create: (context) => AuthModel(),
      child: MaterialApp(
        navigatorKey: navigatorKey,
        title: 'HahAI',
        debugShowCheckedModeBanner: false,
        home: const SplashScreen(),
        theme: ThemeData(
          inputDecorationTheme: const InputDecorationTheme(
            focusColor:Config.primaryColor,
            border: Config.outlinedBorder,
            focusedBorder: Config.focusBorder,
            errorBorder: Config.errorBorder,
            enabledBorder: Config.outlinedBorder,
            floatingLabelStyle: TextStyle(color:Config.primaryColor),
            prefixIconColor: Colors.black38,
          ),
          scaffoldBackgroundColor: Colors.white,
          bottomNavigationBarTheme: BottomNavigationBarThemeData(
            backgroundColor:Config.primaryColor,
            selectedItemColor: Colors.white,
            showSelectedLabels: true,
            showUnselectedLabels: false,
            unselectedItemColor: Colors.grey.shade700,
            elevation: 10,
            type: BottomNavigationBarType.fixed,
          ),
          textTheme: TextTheme(
            bodyMedium: TextStyle(
              fontFamily: 'NeoSans', // Set your desired font family
            ),
            // Add more text styles as needed
          ),
          appBarTheme: AppBarTheme(
            color:Config.primaryColor, // Set the app bar color globally
            titleTextStyle: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontFamily: 'NeoSans',
            ),
            iconTheme: IconThemeData(
              color: Colors.white, // Set the back button color to white
            ),

          ),
        ),
        routes: {
          'login': (context) => const AuthPage(),
          'main': (context) => const MainLayout(),
        },
      ),
    );
  }
}
class AuthUtils {
  static Future<void> checkLoginStatus(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? userId = prefs.getInt('id');
    final tokenValue = prefs.getString('token') ?? '';
    navigateToScreen(context, 'main');

    }

  static void navigateToScreen(BuildContext context, String routeName) {
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      Navigator.of(context).pushReplacementNamed(routeName);
    });
  }
}



class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}
class _SplashScreenState extends State<SplashScreen> {
  late DioProvider dioProvider; // Tambahkan variabel dioProvider

  late final FirebaseMessaging _messaging;
  late int _totalNotifications;
  PushNotification? _notificationInfo;


  void registerNotification() async {

    _messaging = FirebaseMessaging.instance;

    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      provisional: false,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted permission');

      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        print(
            'Message title: ${message.notification?.title}, body: ${message.notification?.body}, data: ${message.data}');

        // Parse the message received
        PushNotification notification = PushNotification(
          title: message.notification?.title,
          body: message.notification?.body,
          dataTitle: message.data['title'],
          dataBody: message.data['body'],
        );

        // Use safeSetState to check whether the widget is still mounted
        safeSetState(() {
          _notificationInfo = notification;
          _totalNotifications++;
        });

        if (_notificationInfo != null) {
          // For displaying the notification as an overlay
          showSimpleNotification(
            Text(_notificationInfo!.title!),
            leading: NotificationBadge(totalNotifications: _totalNotifications),
            subtitle: Row(
              children: [
                // Add your logo widget here
                Image.asset('assets/logo.png', width: 40, height: 40),
                SizedBox(width: 8), // Adjust spacing as needed
                Text(_notificationInfo!.body!),
              ],
            ),
            background: Colors.cyan.shade700,
            duration: Duration(seconds: 2),
          );

        }
      });
    } else {
      print('User declined or has not accepted permission');
    }
  }

// Add this method to check whether the widget is mounted
  void safeSetState(VoidCallback fn) {
    if (mounted) {
      setState(fn);
    }
  }


  // For handling notification when the app is in terminated state
  checkForInitialMessage() async {

    RemoteMessage? initialMessage =
    await FirebaseMessaging.instance.getInitialMessage();

    if (initialMessage != null) {
      PushNotification notification = PushNotification(
        title: initialMessage.notification?.title,
        body: initialMessage.notification?.body,
        dataTitle: initialMessage.data['title'],
        dataBody: initialMessage.data['body'],
      );

      setState(() {
        _notificationInfo = notification;
        _totalNotifications++;
      });
    }
  }

  @override
  void initState() {
    _totalNotifications = 0;
    registerNotification();
    checkForInitialMessage();

    // For handling notification when the app is in background
    // but not terminated
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      PushNotification notification = PushNotification(
        title: message.notification?.title,
        body: message.notification?.body,
        dataTitle: message.data['title'],
        dataBody: message.data['body'],
      );

      setState(() {
        _notificationInfo = notification;
        _totalNotifications++;
      });
    });

    super.initState();
    AuthUtils.checkLoginStatus(context);
  }

  @override
  void dispose() {
    // Dispose resources here if needed
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Tambahkan logo atau gambar splash screen dengan ukuran yang lebih besar
            Image.asset('assets/logo.png', width: 150, height: 150),
            SizedBox(height: 20),
            // Ganti CircularProgressIndicator dengan widget yang lebih menarik, misalnya CircularProgressIndicator dengan warna berbeda
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.blue), // Ganti warna sesuai keinginan Anda
            ),
            SizedBox(height: 20),
            // Tambahkan teks atau widget lainnya di bawah CircularProgressIndicator
            Text(
              'Loading...',
              style: TextStyle(fontSize: 16),
            ),

          ],
        ),
      ),
    );
  }

}

class NotificationBadge extends StatelessWidget {
  final int totalNotifications;

  const NotificationBadge({required this.totalNotifications});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40.0,
      height: 40.0,
      decoration: new BoxDecoration(
        color: Colors.red,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            '$totalNotifications',
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
        ),
      ),
    );
  }
}






