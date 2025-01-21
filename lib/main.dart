// ignore_for_file: avoid_print

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:collab_mitra/database/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screen/login_page.dart';
import 'screen/signup_page.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:localization/localization.dart';

void main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();
    AwesomeNotifications().initialize(null, [
      NotificationChannel(
          channelKey: 'anggaran',
          channelName: "Batas Anggaran",
          channelDescription: "Memberitahu batas anggaran"),
      NotificationChannel(
          channelKey: 'penjualan',
          channelName: "Batas Penjualan",
          channelDescription: "Memberitahu batas penjualan")
    ]);
    await Firebase.initializeApp();
    runApp(ChangeNotifierProvider(
        create: (context) => ProviderHelper(), child: const MyApp()));
  } catch (e) {
    print('karena $e');
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    LocalJsonLocalization.delegate.directories = ['lib/i18n'];
    return MaterialApp(
      supportedLocales: const [
        Locale("en", "US"),
        Locale("id", "ID"),
      ],
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        LocalJsonLocalization.delegate
      ],
      localeResolutionCallback: (locale, supportedLocales) {
        if (supportedLocales.contains(locale)) {
          return locale;
        }
        return const Locale('id', 'ID');
      },
      title: 'Jaya Mart',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: false,
        primarySwatch: Colors.green,
      ),
      home: const SignupPage(),
      // Riwayat(uid: 'RJw6jawUXeeAewfNMdU3qzH5MTs2'),
      // Profil(list: ['ogddXQ58mjVBO7CTAaXb9n7CH4w2', 'chris@gmail.com']),
      routes: {
        '/login': (context) => const LoginPage(),
        '/signup': (context) => const SignupPage(),
      },
    );
  }
}
