import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'firebase_options.dart';
import 'screen/map_scrren.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  print('Loading .env file...');
  try {
    await dotenv.load(fileName: ".env");
    print('.env loaded successfully');
  } catch (e) {
    print('Failed to load .env: $e');
  }

  print('Initializing Firebase...');
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('Firebase initialized');
  } catch (e) {
    print('Firebase initialization error: $e');
  }

  runApp(const MyApp());
  print('runApp executed');
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Backpack',
      theme: ThemeData(primarySwatch: Colors.deepPurple),
      home: const MapScreen(),
    );
  }
}
