import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'dart:math' as math;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MaterialApp(home: DashboardScreen()));
}

// Firebase service to get backpack data stream
class FirebaseService {
  final DatabaseReference _database = FirebaseDatabase.instance.ref();

  Stream<DatabaseEvent> getBackpackDataStream() {
    return _database.child('backpack').onValue;
  }
}

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final FirebaseService _firebaseService = FirebaseService();

  String currentOrientation = 'vertical';
  String pressureKg = '0';
  bool waterLeak = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: const Text(
          'Smart Backpack',
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: StreamBuilder<DatabaseEvent>(
        stream: _firebaseService.getBackpackDataStream(),
        builder: (context, snapshot) {
          if (snapshot.hasData && snapshot.data!.snapshot.value != null) {
            Map data = snapshot.data!.snapshot.value as Map;

            currentOrientation = (data['position'] ?? 'vertical').toString();

            if (data['pressure'] != null && data['pressure']['kg'] != null) {
              pressureKg = data['pressure']['kg'].toString();
            } else {
              pressureKg = '0';
            }

            if (data['water-leak-detection'] != null &&
                data['water-leak-detection']['water-leak'] != null) {
              var leakVal = data['water-leak-detection']['water-leak'];
              waterLeak = leakVal == true || leakVal == 'true';
            } else {
              waterLeak = false;
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const BatteryIndicator(batteryLevel: 0.76),
                  const SizedBox(height: 20),
                  BagOverviewCard(orientation: currentOrientation),
                  const SizedBox(height: 20),
                  GridView.count(
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    children: [
                      const InfoCard(
                        title: 'Items Detected',
                        icon: Icons.inventory_2,
                        value: '4',
                        iconColor: Colors.orange,
                      ),
                      InfoCard(
                        title: 'Pressure',
                        icon: Icons.monitor_weight,
                        value: '$pressureKg kg',
                        iconColor: Colors.deepPurple,
                      ),
                      const InfoCard(
                        title: 'Last Sync',
                        icon: Icons.update,
                        value: '5 min ago',
                        iconColor: Colors.blue,
                      ),
                      WaterLeakCard(waterLeakDetected: waterLeak),
                    ],
                  ),
                ],
              ),
            );
          }

          if (snapshot.hasError) {
            return const Center(child: Text('Error loading data'));
          }

          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}

class BatteryIndicator extends StatelessWidget {
  final double batteryLevel;

  const BatteryIndicator({super.key, required this.batteryLevel});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.grey.shade300, blurRadius: 6)],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: Row(
        children: [
          const Icon(Icons.battery_full, color: Colors.green, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: LinearProgressIndicator(
              value: batteryLevel,
              backgroundColor: Colors.grey[300],
              color: Colors.green,
              minHeight: 10,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            '${(batteryLevel * 100).toInt()}%',
            style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

class BagOverviewCard extends StatelessWidget {
  final String orientation;

  const BagOverviewCard({super.key, required this.orientation});

  double _getAngleInRadians(String pos) {
    switch (pos.toLowerCase()) {
      case 'horizontal':
        return 90 * math.pi / 180;
      case 'upside':
        return 180 * math.pi / 180;
      default:
        return 0; // vertical
    }
  }

  String _getLabel(String pos) {
    switch (pos.toLowerCase()) {
      case 'horizontal':
        return 'Horizontal';
      case 'upside':
        return 'Upside Down';
      default:
        return 'Vertical';
    }
  }

  @override
  Widget build(BuildContext context) {
    final angle = _getAngleInRadians(orientation);
    final label = _getLabel(orientation);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 32),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.grey.shade300, blurRadius: 10)],
      ),
      child: Column(
        children: [
          Transform.rotate(
            angle: angle,
            child: Image.asset(
              'assets/images/backpack.png',
              height: 80,
              width: 80,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            label,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
          ),
        ],
      ),
    );
  }
}

class InfoCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final String value;
  final Color iconColor;

  const InfoCard({
    super.key,
    required this.title,
    required this.icon,
    required this.value,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.grey.shade200, blurRadius: 6)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: iconColor, size: 28),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(color: Colors.grey[600], fontSize: 14),
          ),
        ],
      ),
    );
  }
}

class WaterLeakCard extends StatefulWidget {
  final bool waterLeakDetected;

  const WaterLeakCard({super.key, required this.waterLeakDetected});

  @override
  State<WaterLeakCard> createState() => _WaterLeakCardState();
}

class _WaterLeakCardState extends State<WaterLeakCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Color?> _colorAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );

    _colorAnimation = ColorTween(
      begin: Colors.white,
      end: Colors.lightBlue.shade100,
    ).animate(_controller);

    if (widget.waterLeakDetected) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(covariant WaterLeakCard oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.waterLeakDetected && !_controller.isAnimating) {
      _controller.repeat(reverse: true);
    } else if (!widget.waterLeakDetected && _controller.isAnimating) {
      _controller.stop();
      _controller.reset();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _colorAnimation,
      builder: (context, child) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: widget.waterLeakDetected ? _colorAnimation.value : Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: Colors.grey.shade200, blurRadius: 6)],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.water_drop,
                color: Colors.teal,
                size: 28,
              ),
              const Spacer(),
              Text(
                widget.waterLeakDetected ? 'Wet' : 'No Leak',
                style: TextStyle(
                  color: widget.waterLeakDetected ? Colors.teal.shade700 : Colors.black,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Water Leak',
                style: TextStyle(color: Colors.grey, fontSize: 14),
              ),
            ],
          ),
        );
      },
    );
  }
}
