import 'package:ads_mayhem_2/PAGES/get_started.dart';
import 'package:ads_mayhem_2/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_library_latest/MODELS/datamaster.dart';

void main() async {
  final dm = DataMaster();
  await dm.getStarted();
  dm.setAppName('KoukokuAds');
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp(dm: dm));
}

class MyApp extends StatelessWidget {
  final DataMaster dm;
  const MyApp({super.key, required this.dm});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: GetStarted(dm: dm),
    );
  }
}
