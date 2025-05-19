import 'package:flutter/material.dart';
import '../service/firebase_service.dart';
import '../widget/battery_indicator.dart';
import '../widget/info_card.dart';
import '../widget/bag_overview_card.dart';



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
              BagOverviewCard(orientation: orientation),
              const SizedBox(height: 20),
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
              GridView.count(
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 1,
                shrinkWrap: true,
                childAspectRatio: 3.5,
                children: [
                  InfoCard(title: 'Left Pressure (Sensor1)', icon: Icons.speed, value: '$sensor1 kg', iconColor: Colors.purple),
                  InfoCard(title: 'Right Pressure (Sensor2)', icon: Icons.speed, value: '$sensor2 kg', iconColor: Colors.pink),
                  InfoCard(title: 'Net Weight', icon: Icons.fitness_center, value: '$net kg', iconColor: Colors.indigo),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class BlinkingCard extends StatefulWidget {
  final String title;
  final IconData icon;
  final String value;
  final Color iconColor;
  final bool shouldBlink;

  const BlinkingCard({
    super.key,
    required this.title,
    required this.icon,
    required this.value,
    required this.iconColor,
    required this.shouldBlink,
  });

  @override
  State<BlinkingCard> createState() => _BlinkingCardState();
}

class _BlinkingCardState extends State<BlinkingCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Color?> _colorTween;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: const Duration(milliseconds: 800), vsync: this)..repeat(reverse: true);
    _colorTween = ColorTween(begin: Colors.white, end: Colors.red[100]).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (_, child) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: widget.shouldBlink ? _colorTween.value : Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: Colors.grey.shade200, blurRadius: 6)],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(widget.icon, color: widget.iconColor, size: 28),
              const Spacer(),
              Text(widget.value, style: const TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(widget.title, style: TextStyle(color: Colors.grey[600], fontSize: 14)),
            ],
          ),
        );
      },
    );
  }
}
