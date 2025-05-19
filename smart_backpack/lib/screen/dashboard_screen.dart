import 'package:flutter/material.dart';
import '../service/firebase_service.dart';
import '../widget/battery_indicator.dart';
import '../widget/blinking_card.dart';
import '../widget/bag_overview_card.dart';
import '../widget/info_card.dart'; // ✅ Ensure InfoCard is imported

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String orientation = 'UNKNOWN';
  bool isWaterLeaking = false;
  double sensor1 = 0;
  double sensor2 = 0;
  double net = 0;

  final FirebaseService _firebaseService = FirebaseService();

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    final pos = await _firebaseService.getBackpackPosition();
    final waterLeak = await _firebaseService.getWaterLeakStatus();
    final pressure = await _firebaseService.getPressureData();

    setState(() {
      orientation = pos;
      isWaterLeaking = waterLeak;
      sensor1 = double.tryParse(pressure['sensor1'].toString()) ?? 0;
      sensor2 = double.tryParse(pressure['sensor2'].toString()) ?? 0;
      net = double.tryParse(pressure['net'].toString()) ?? 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: const Text('Smart Backpack', style: TextStyle(color: Colors.black)),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: RefreshIndicator(
        onRefresh: fetchData,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const BatteryIndicator(batteryLevel: 0.76),
              const SizedBox(height: 20),

              /// ✅ Left & Right Pressure Indicators (Before Backpack)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  LeftPressureIndicator(sensor1: sensor1),
                  RightPressureIndicator(sensor2: sensor2),
                ],
              ),
              
              const SizedBox(height: 20),

              /// ✅ Backpack Overview
              BagOverviewCard(orientation: orientation),

              const SizedBox(height: 20),

              /// ✅ Smart Backpack Status Details
              GridView.count(
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                shrinkWrap: true,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  const InfoCard(title: 'Items Detected', icon: Icons.inventory_2, value: '4', iconColor: Colors.orange),
                  const InfoCard(title: 'Temperature', icon: Icons.thermostat, value: '32°C', iconColor: Colors.redAccent),
                  const InfoCard(title: 'Last Sync', icon: Icons.update, value: '5 min ago', iconColor: Colors.blue),
                  BlinkingCard(
                    title: 'Water Detect',
                    icon: Icons.water_drop,
                    value: isWaterLeaking ? 'Leak Detected' : 'None',
                    iconColor: isWaterLeaking ? Colors.red : Colors.teal,
                    shouldBlink: isWaterLeaking,
                  ),
                ],
              ),
              const SizedBox(height: 20),

              /// ✅ Net Weight Display
              InfoCard(
                title: 'Net Weight',
                icon: Icons.fitness_center,
                value: '$net kg',
                iconColor: Colors.indigo,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class LeftPressureIndicator extends StatelessWidget {
  final double sensor1;
  final String imagePath = "assests/left_side.png"; // ✅ Single image

  const LeftPressureIndicator({super.key, required this.sensor1});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: sensor1 > 5 ? Colors.red.withOpacity(0.3) : Colors.transparent, // ✅ Dynamic warning background
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Image.asset(imagePath, width: 80, height: 80), // ✅ Always use same image
          const SizedBox(height: 6),
          Text(
            "$sensor1 kg",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: sensor1 > 5 ? Colors.red : Colors.black, // ✅ Dynamic text color
            ),
          ),
        ],
      ),
    );
  }
}

class RightPressureIndicator extends StatelessWidget {
  final double sensor2;
  final String imagePath = "assests/right_side.png"; // ✅ Single image

  const RightPressureIndicator({super.key, required this.sensor2});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: sensor2 > 5 ? Colors.red.withOpacity(0.3) : Colors.transparent, // ✅ Dynamic warning background
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Image.asset(imagePath, width: 80, height: 80), // ✅ Always use same image
          const SizedBox(height: 6),
          Text(
            "$sensor2 kg",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: sensor2 > 5 ? Colors.red : Colors.black, // ✅ Dynamic text color
            ),
          ),
        ],
      ),
    );
  }
}
