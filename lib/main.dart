import 'package:beermate_2/firebase_options.dart';
import 'package:beermate_2/screens/starter_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeFirebase(); // csak egyszer kell fusson
  runApp(const MyApp());
}

Future<void> initializeFirebase() async {
  await Firebase.initializeApp(
  name: 'beermate2',
  options: DefaultFirebaseOptions.currentPlatform,
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'BeerMate',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const StarterPage(),
    );
  }
}
