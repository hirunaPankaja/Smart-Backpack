import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'firebase_options.dart';
import 'screen/dashboard_screen.dart';

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

  // Initialize Awesome Notifications
  print('Initializing Awesome Notifications...');
  try {
    await AwesomeNotifications().initialize(
      null, // Use default app icon
      [
        NotificationChannel(
          channelKey: 'smart_backpack_alerts',
          channelName: 'Smart Backpack Alerts',
          channelDescription: 'Notifications for smart backpack events',
          defaultColor: const Color(0xFF9D50DD),
          ledColor: Colors.white,
          importance: NotificationImportance.High,
          channelShowBadge: true,
          playSound: true,
          enableVibration: true,
          soundSource: 'resource://raw/notification', // Your MP3 file
        ),
      ],
    );
    print('Awesome Notifications initialized');

    // Request notification permissions
    bool isAllowed = await AwesomeNotifications().isNotificationAllowed();
    if (!isAllowed) {
      await AwesomeNotifications().requestPermissionToSendNotifications();
    }
    print('Notification permissions: $isAllowed');
  } catch (e) {
    print('Awesome Notifications initialization error: $e');
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
      home: const DashboardScreen(),
    );
  }
}