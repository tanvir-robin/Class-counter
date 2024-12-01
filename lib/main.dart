import 'package:class_counter/firebase_options.dart';
import 'package:class_counter/views/home_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
      MaterialApp(theme: ThemeData(useMaterial3: false), home: HomeScreen()));
}
