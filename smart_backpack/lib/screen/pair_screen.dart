import 'package:flutter/material.dart';

void main() {
  runApp(const SmartBackpackApp());
}

class SmartBackpackApp extends StatelessWidget {
  const SmartBackpackApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Backpack UI',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const PairScreen(),
    );
  }
}

class PairScreen extends StatelessWidget {
  const PairScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(backgroundColor: Colors.black, elevation: 0),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.center, // ✅ Center horizontally
          mainAxisAlignment: MainAxisAlignment.start, // ✅ Align to the top
          children: [
            const SizedBox(
              height: 40,
            ), // ✅ Push content lower but still near top
            const Text(
              'Good Afternoon',
              textAlign: TextAlign.center, // ✅ Center text horizontally
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'If you have a Smart Backpack, you can pair it with your phone here.',
              textAlign: TextAlign.center, // ✅ Center second text too
              style: TextStyle(fontSize: 18, color: Colors.white),
            ),
            const SizedBox(height: 30),
            Center(
              child: Image.asset(
                'assets/pair_screen.png', // ✅ Corrected path
                height: 550, // ✅ Increased image size
                width: 550, // ✅ Adjust width as needed
              ),
            ),
            const SizedBox(height: 40),
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 27, 22, 16),
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  minimumSize: const Size(220, 50), // ✅ Increased button width
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () {
                  // Pairing action logic here
                },
                child: const Text(
                  'Start Pairing',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ), // ✅ Fixed text color
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
