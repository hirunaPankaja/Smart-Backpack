import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/pressure_data.dart';
import '../service/firebase_service.dart';
import 'dart:async';

class PressureAnalysisScreen extends StatefulWidget {
  final FirebaseService firebaseService;
  
  const PressureAnalysisScreen({
    super.key,
    required this.firebaseService,
  });

  @override
  State<PressureAnalysisScreen> createState() => _PressureAnalysisScreenState();
}

class _PressureAnalysisScreenState extends State<PressureAnalysisScreen> {
  StreamSubscription<PressureData>? _pressureSubscription;
  PressureData? _currentPressure;
  PressureAnalytics? _analytics;
  int _selectedHours = 24;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _startPressureMonitoring();
    _loadAnalytics();
  }

  void _startPressureMonitoring() {
    _pressureSubscription = widget.firebaseService.pressureDataStream().listen(
      (pressureData) {
        if (mounted) {
          setState(() {
            _currentPressure = pressureData;
            _isLoading = false;
          });
          // Refresh analytics every 10 readings
          if (pressureData.timestamp.second % 10 == 0) {
            _loadAnalytics();
          }
        }
      },
      onError: (error) {
        print('Pressure stream error: $error');
        if (mounted) {
          setState(() => _isLoading = false);
        }
      },
    );
  }

  void _loadAnalytics() {
    final analytics = widget.firebaseService.getPressureAnalytics(hours: _selectedHours);
    if (mounted) {
      setState(() => _analytics = analytics);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Pressure Monitor', style: TextStyle(fontWeight: FontWeight.w600)),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.blue),
            onPressed: _loadAnalytics,
          ),
        ],
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
            child: Column(
              children: [
                _buildCurrentPressureCard(),
                _buildTimeRangeSelector(),
                _buildPressureChart(),
                _buildAnalyticsCard(),
                _buildTipsCard(),
                const SizedBox(height: 20),
              ],
            ),
          ),
    );
  }

  Widget _buildCurrentPressureCard() {
    if (_currentPressure == null) {
      return Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
        ),
        child: const Center(
          child: Text('Waiting for pressure data...', style: TextStyle(color: Colors.grey)),
        ),
      );
    }

    final left = _currentPressure!.left;
    final right = _currentPressure!.right;
    final total = left + right;
    final isBalanced = (left - right).abs() < (total * 0.1);

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isBalanced 
            ? [Colors.green.shade400, Colors.green.shade600]
            : [Colors.orange.shade400, Colors.orange.shade600],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 15)],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                isBalanced ? Icons.balance : Icons.warning_rounded,
                color: Colors.white,
                size: 28,
              ),
              const SizedBox(width: 12),
              Text(
                isBalanced ? 'BALANCED' : 'IMBALANCED',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildPressureDisplay('LEFT', left, Colors.blue.shade300),
              ),
              Container(
                width: 2,
                height: 40,
                color: Colors.white.withOpacity(0.3),
              ),
              Expanded(
                child: _buildPressureDisplay('RIGHT', right, Colors.red.shade300),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'Total: ${total.toStringAsFixed(0)}g',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPressureDisplay(String label, double value, Color accentColor) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.8),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: accentColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            '${value.toStringAsFixed(0)}g',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTimeRangeSelector() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          const Text('Time Range: ', style: TextStyle(fontWeight: FontWeight.w500)),
          Expanded(
            child: Row(
              children: [1, 6, 24, 48].map((hours) {
                final isSelected = _selectedHours == hours;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text('${hours}h'),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() => _selectedHours = hours);
                      _loadAnalytics();
                    },
                    selectedColor: Colors.blue.shade100,
                    checkmarkColor: Colors.blue,
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPressureChart() {
    final history = widget.firebaseService.getPressureHistory(limitHours: _selectedHours);
    
    if (history.isEmpty) {
      return Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(40),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
        ),
        child: Center(
          child: Column(
            children: [
              Icon(Icons.timeline, size: 48, color: Colors.grey.shade400),
              const SizedBox(height: 16),
              Text(
                'No historical data yet',
                style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
              ),
              const Text('Chart will appear as data is collected'),
            ],
          ),
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Pressure History',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawHorizontalLine: true,
                  drawVerticalLine: false,
                  horizontalInterval: 200,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: Colors.grey.shade200,
                    strokeWidth: 1,
                  ),
                ),
                titlesData: FlTitlesData(
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: _getTimeInterval(),
                      getTitlesWidget: (value, meta) {
                        final date = DateTime.fromMillisecondsSinceEpoch(value.toInt());
                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            _formatTime(date),
                            style: const TextStyle(fontSize: 10, color: Colors.grey),
                          ),
                        );
                      },
                      reservedSize: 30,
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 200,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          '${value.toInt()}g',
                          style: const TextStyle(fontSize: 10, color: Colors.grey),
                        );
                      },
                      reservedSize: 40,
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  // Left pressure line
                  LineChartBarData(
                    spots: history.map((data) => FlSpot(
                      data.timestamp.millisecondsSinceEpoch.toDouble(),
                      data.left,
                    )).toList(),
                    isCurved: true,
                    curveSmoothness: 0.1,
                    color: Colors.blue,
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      color: Colors.blue.withOpacity(0.1),
                    ),
                  ),
                  // Right pressure line
                  LineChartBarData(
                    spots: history.map((data) => FlSpot(
                      data.timestamp.millisecondsSinceEpoch.toDouble(),
                      data.right,
                    )).toList(),
                    isCurved: true,
                    curveSmoothness: 0.1,
                    color: Colors.red,
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      color: Colors.red.withOpacity(0.1),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLegendItem('Left', Colors.blue),
              const SizedBox(width: 24),
              _buildLegendItem('Right', Colors.red),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 16,
          height: 3,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }

  Widget _buildAnalyticsCard() {
    if (_analytics == null) return const SizedBox();

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Analysis Summary',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Left Average', 
                  '${_analytics!.leftAvg.toStringAsFixed(0)}g',
                  Colors.blue,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Right Average', 
                  '${_analytics!.rightAvg.toStringAsFixed(0)}g',
                  Colors.red,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _getImbalanceColor().withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(_getImbalanceIcon(), color: _getImbalanceColor(), size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Balance Status',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      Text(
                        '${_analytics!.imbalancePercentage.toStringAsFixed(1)}% imbalance',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: _getImbalanceColor(),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTipsCard() {
    if (_analytics == null || _analytics!.recommendations.isEmpty) {
      return const SizedBox();
    }

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.lightbulb_outline, color: Colors.amber.shade600),
              const SizedBox(width: 8),
              const Text(
                'Smart Tips',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ..._analytics!.recommendations.map((tip) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tip.split(' ').first, // Get emoji
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    tip.substring(tip.indexOf(' ') + 1), // Remove emoji
                    style: const TextStyle(fontSize: 14, height: 1.4),
                  ),
                ),
              ],
            ),
                      )).toList(),
        ],
      ),
    );
  }

  // Helper methods for chart formatting
  double _getTimeInterval() {
    if (_selectedHours <= 6) return 3600000; // 1 hour for short ranges
    if (_selectedHours <= 24) return 10800000; // 3 hours for medium ranges
    return 21600000; // 6 hours for longer ranges
  }

  String _formatTime(DateTime date) {
    if (_selectedHours <= 6) {
      return '${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } else {
      return '${date.hour}:00';
    }
  }

  Color _getImbalanceColor() {
    if (_analytics == null) return Colors.grey;
    final percentage = _analytics!.imbalancePercentage;
    
    if (percentage < 10) return Colors.green;
    if (percentage < 20) return Colors.blue;
    if (percentage < 30) return Colors.orange;
    return Colors.red;
  }

  IconData _getImbalanceIcon() {
    if (_analytics == null) return Icons.help_outline;
    final percentage = _analytics!.imbalancePercentage;
    
    if (percentage < 10) return Icons.check_circle_outline;
    if (percentage < 20) return Icons.info_outline;
    if (percentage < 30) return Icons.warning_amber_outlined;
    return Icons.error_outline;
  }

  @override
  void dispose() {
    _pressureSubscription?.cancel();
    super.dispose();
  }
}