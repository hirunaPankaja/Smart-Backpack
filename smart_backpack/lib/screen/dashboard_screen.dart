import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_backpack/widget/MapNavigationWidget.dart';
import '../service/firebase_service.dart';
import '../widget/battery_indicator.dart';
import '../widget/blinking_card.dart';
import '../widget/bag_overview_card.dart';
import '../widget/info_card.dart';
import '../dialogs/pressure_adjustment_popup.dart';
import '../widget/InsideBagPressure.dart';
import '../widget/net_weight_widget.dart';
import '../widget/temperature_humidity_widget.dart';


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
  Map<String, String> cardNames = {};
  Map<String, String> cardStatuses = {};
  double batteryLevel = 0;
  bool isCharging = false;
  bool _isOnline = true;
  DateTime? _lastSyncTime;
  double temperature = 0.0;
  double humidity = 0.0;

  final FirebaseService _firebaseService = FirebaseService();
  late DatabaseReference _positionRef;
  late DatabaseReference _waterLeakRef;
  late DatabaseReference _pressureRef;
  late DatabaseReference _cardsRef;
  late DatabaseReference _batteryRef;
  late DatabaseReference _temperatureRef;
  late DatabaseReference _humidityRef;

  @override
  void initState() {
    super.initState();
    _loadCardNames();
    _setupRealTimeListeners();
  }

  String getSyncStatusText() {
    if (_isOnline) return 'Just now';
    if (_lastSyncTime == null) return 'Offline';

    final minutes = DateTime.now().difference(_lastSyncTime!).inMinutes;
    return '$minutes minute${minutes == 1 ? '' : 's'} ago';
  }

  Future<void> _loadCardNames() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      cardNames = {
        'card1': prefs.getString('card1_name') ?? 'Card 1',
        'card2': prefs.getString('card2_name') ?? 'Card 2',
        'card3': prefs.getString('card3_name') ?? 'Card 3',
        'card4': prefs.getString('card4_name') ?? 'Card 4',
      };
    });
  }

  Future<void> _saveCardName(String cardKey, String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('${cardKey}_name', name);
    setState(() {
      cardNames[cardKey] = name;
    });
  }

  void _setupRealTimeListeners() {
    _positionRef = _firebaseService.getPositionRef();
    _waterLeakRef = _firebaseService.getWaterLeakRef();
    _pressureRef = _firebaseService.getPressureRef();
    _cardsRef = _firebaseService.getCardsRef();
    _batteryRef = _firebaseService.getBatteryRef();
    _temperatureRef =
        _firebaseService.getTemperatureRef(); // ✅ Ensure this is set first
    _humidityRef = _firebaseService.getHumidityRef();

    _positionRef.onValue.listen((event) {
      setState(() {
        _isOnline = true;
        _lastSyncTime = DateTime.now();
        final data = event.snapshot.value;
        if (data != null) {
          orientation = data.toString();
        }
      });
    });

    _waterLeakRef.onValue.listen((event) {
      setState(() {
        _isOnline = true;
        _lastSyncTime = DateTime.now();
        final data = event.snapshot.value;
        if (data != null) {
          isWaterLeaking = data == true;
        }
      });
    });

    _pressureRef.onValue.listen((event) {
      setState(() {
        _isOnline = true;
        _lastSyncTime = DateTime.now();
        final data = event.snapshot.value as Map?;
        if (data != null) {
          sensor1 = double.tryParse(data['sensor1'].toString()) ?? 0;
          sensor2 = double.tryParse(data['sensor2'].toString()) ?? 0;
          net = double.tryParse(data['net'].toString()) ?? 0;
        }
      });
    });

    _cardsRef.onValue.listen((event) {
      setState(() {
        _isOnline = true;
        _lastSyncTime = DateTime.now();
        final data = event.snapshot.value as Map?;
        if (data != null) {
          cardStatuses = Map<String, String>.from(
            data.map(
              (key, value) =>
                  MapEntry(key.toString(), (value as Map)['status'].toString()),
            ),
          );
        }
      });
    });

    _temperatureRef.onValue.listen((event) {
      setState(() {
        final data = event.snapshot.value;
        if (data != null) {
          temperature = double.tryParse(data.toString()) ?? 0.0;
        }
      });
    });

    _humidityRef.onValue.listen((event) {
      setState(() {
        final data = event.snapshot.value;
        if (data != null) {
          humidity = double.tryParse(data.toString()) ?? 0.0;
        }
      });
    });

    _batteryRef.onValue.listen((event) {
      setState(() {
        _isOnline = true;
        _lastSyncTime = DateTime.now();
        final data = event.snapshot.value as Map?;
        if (data != null) {
          batteryLevel = double.tryParse(data['level'].toString()) ?? 0;
          isCharging = data['isCharging'] == true;
        }
      });
    });

    // Error listeners for offline detection
    _positionRef.onValue.listen(
      (event) {},
      onError: (error) {
        setState(() => _isOnline = false);
      },
    );
    _waterLeakRef.onValue.listen(
      (event) {},
      onError: (error) {
        setState(() => _isOnline = false);
      },
    );
    _pressureRef.onValue.listen(
      (event) {},
      onError: (error) {
        setState(() => _isOnline = false);
      },
    );
    _cardsRef.onValue.listen(
      (event) {},
      onError: (error) {
        setState(() => _isOnline = false);
      },
    );
    _batteryRef.onValue.listen(
      (event) {},
      onError: (error) {
        setState(() => _isOnline = false);
      },
    );
  }

  void _showCardNamingDialog(BuildContext context) {
    final cardKeys = cardNames.keys.toList();
    final cardIds = cardStatuses.keys.toList();

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Name Your Cards'),
            content: SizedBox(
              width: double.maxFinite,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: cardNames.length,
                itemBuilder: (context, index) {
                  final cardKey = cardKeys[index];
                  final cardId =
                      index < cardIds.length ? cardIds[index] : 'N/A';
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text('Card ${index + 1} (ID: $cardId)'),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          flex: 2,
                          child: TextFormField(
                            initialValue: cardNames[cardKey],
                            onChanged: (value) => _saveCardName(cardKey, value),
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Done'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final itemsIn =
        cardStatuses.values.where((status) => status == 'IN').length;
    final totalItems = cardStatuses.length;
    final missingItems =
        cardStatuses.entries.where((entry) => entry.value == 'OUT').map((
          entry,
        ) {
          final index = cardStatuses.keys.toList().indexOf(entry.key);
          return index < cardNames.length
              ? cardNames.values.elementAt(index)
              : 'Card ${index + 1}';
        }).toList();

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
      body: RefreshIndicator(
        onRefresh: () async {
          // Force refresh if needed
          final pressure = await _firebaseService.getPressureData();
          final cards = await _firebaseService.getCardsData();
          final battery = await _firebaseService.getBatteryData();

          setState(() {
            _isOnline = true;
            _lastSyncTime = DateTime.now();
            sensor1 = double.tryParse(pressure['sensor1'].toString()) ?? 0;
            sensor2 = double.tryParse(pressure['sensor2'].toString()) ?? 0;
            net = double.tryParse(pressure['net'].toString()) ?? 0;
            cardStatuses = Map<String, String>.from(
              cards.map(
                (key, value) =>
                    MapEntry(key.toString(), value['status'].toString()),
              ),
            );
            batteryLevel = double.tryParse(battery['level'].toString()) ?? 0;
            isCharging = battery['isCharging'] == true;
          });
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              TemperatureHumidityWidget(
                onDataReceived: (temp, hum) {
                  setState(() {
                    temperature = temp;
                    humidity = hum;
                  });
                },
              ),
              BatteryIndicator(
                batteryLevel: batteryLevel,
                isCharging: isCharging,
              ),
              const SizedBox(height: 20),

              /// Left & Right Pressure Indicators (Before Backpack)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  LeftPressureIndicator(sensor1: sensor1),
                  RightPressureIndicator(sensor2: sensor2),
                ],
              ),

              const SizedBox(height: 20),

              /// Backpack Overview
              BagOverviewCard(orientation: orientation),

              const SizedBox(height: 20),

              /// Smart Backpack Status Details
              GridView.count(
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                shrinkWrap: true,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  Stack(
                    children: [
                      InfoCard(
                        title: 'Items Detected',
                        icon: Icons.inventory_2,
                        value: '$itemsIn/$totalItems',
                        iconColor: Colors.orange,
                        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
                      ),
                      Positioned(
                        top: 8,
                        right: 8,
                        child: IconButton(
                          icon: const Icon(Icons.edit, size: 18),
                          onPressed: () => _showCardNamingDialog(context),
                        ),
                      ),
                    ],
                  ),

              InfoCard(
                 title: 'Temperature & Humidity',
                 icon: Icons.thermostat,
                 value: '${temperature.toStringAsFixed(1)}°C | ${humidity.toStringAsFixed(1)}%',
                 iconColor: (temperature > 35 || humidity > 80) ? Colors.redAccent : Colors.blueAccent,
                 cardColor: (temperature > 35 || humidity > 80) 
                  ? const Color.fromARGB(255, 231, 3, 3)!.withOpacity(0.4) // ✅ Stronger red alert when high values are detected
                  : Colors.white, // ✅ Normal condition (white background)
                 textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black),
                ),

                  InfoCard(
                    title: 'Last Sync',
                    icon: Icons.update,
                    value: getSyncStatusText(),
                    iconColor: Colors.blue,
                    textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
                  ),
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

              /// Missing Items Display
              if (missingItems.isNotEmpty)
                Column(
                  children:
                      missingItems
                          .map(
                            (itemName) => Container(
                              width: double.infinity,
                              margin: const EdgeInsets.only(bottom: 8),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.red[100],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '$itemName is missing',
                                style: TextStyle(
                                  color: Colors.red[800],
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          )
                          .toList(),
                ),

              const SizedBox(height: 20),

              /// Inside Bag Pressure Widget
              GestureDetector(
                onTap: () async {
                  final adjustedPressure = await showDialog(
                    context: context,
                    builder:
                        (context) => PressureAdjustmentPopup(
                          initialPressure: net,
                          onPressureChanged: (newPressure) {
                            setState(() {
                              net = newPressure;
                            });
                          },
                        ),
                  );

                  if (adjustedPressure != null) {
                    setState(() {
                      net = adjustedPressure;
                    });
                  }
                },
                child: InsideBagPressureWidget(insidePressure: net),
              ),

              const SizedBox(height: 20),

              /// Net Weight Display
              NetWeightWidget(netWeight: net),

              const SizedBox(height: 20),

              const MapNavigationWidget(),

              const SizedBox(height: 20),

           
            ],
          ),
        ),
      ),
    );
  }
}

class LeftPressureIndicator extends StatelessWidget {
  final double sensor1;
  final String imagePath = "assests/left_side.png";

  const LeftPressureIndicator({super.key, required this.sensor1});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: sensor1 > 5 ? Colors.red.withOpacity(0.3) : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Image.asset(imagePath, width: 80, height: 80),
          const SizedBox(height: 6),
          Text(
            "$sensor1 kg",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: sensor1 > 5 ? Colors.red : Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}

class RightPressureIndicator extends StatelessWidget {
  final double sensor2;
  final String imagePath = "assests/right_side.png";

  const RightPressureIndicator({super.key, required this.sensor2});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: sensor2 > 5 ? Colors.red.withOpacity(0.3) : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Image.asset(imagePath, width: 80, height: 80),
          const SizedBox(height: 6),
          Text(
            "$sensor2 kg",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: sensor2 > 5 ? Colors.red : Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}