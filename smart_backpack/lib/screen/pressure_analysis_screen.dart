import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../service/firebase_service.dart';
import '../models/pressure_data.dart';

class PressureAnalysisScreen extends StatefulWidget {
  final FirebaseService firebaseService;

  const PressureAnalysisScreen({Key? key, required this.firebaseService}) : super(key: key);

  @override
  _PressureAnalysisScreenState createState() => _PressureAnalysisScreenState();
}

class _PressureAnalysisScreenState extends State<PressureAnalysisScreen> {
  List<PressureData> _pressureHistory = [];
  int _analysisTimeRange = 24;
  final List<int> _timeRangeOptions = [1, 6, 12, 24, 48, 168];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPressureHistory();
  }

  void _loadPressureHistory() async {
    setState(() => _isLoading = true);
    final data = widget.firebaseService.getPressureHistory();
    await Future.delayed(Duration(milliseconds: 500));
    setState(() {
      _pressureHistory = data;
      _isLoading = false;
    });
  }

  List<PressureData> _getFilteredData() {
    final cutoffTime = DateTime.now().subtract(Duration(hours: _analysisTimeRange));
    return _pressureHistory.where((data) => data.timestamp.isAfter(cutoffTime)).toList();
  }

  double _getMax(String type) {
    final filteredData = _getFilteredData();
    if (filteredData.isEmpty) return 0;
    switch (type) {
      case 'left':
        return filteredData.map((e) => e.left).reduce((a, b) => a > b ? a : b);
      case 'right':
        return filteredData.map((e) => e.right).reduce((a, b) => a > b ? a : b);
      case 'net':
        return filteredData.map((e) => e.net).reduce((a, b) => a > b ? a : b);
      default:
        return 0;
    }
  }

  double _getMin(String type) {
    final filteredData = _getFilteredData();
    if (filteredData.isEmpty) return 0;
    switch (type) {
      case 'left':
        return filteredData.map((e) => e.left).reduce((a, b) => a < b ? a : b);
      case 'right':
        return filteredData.map((e) => e.right).reduce((a, b) => a < b ? a : b);
      case 'net':
        return filteredData.map((e) => e.net).reduce((a, b) => a < b ? a : b);
      default:
        return 0;
    }
  }

  double _getAvg(String type) {
    final filteredData = _getFilteredData();
    if (filteredData.isEmpty) return 0;
    switch (type) {
      case 'left':
        return filteredData.map((e) => e.left).reduce((a, b) => a + b) / filteredData.length;
      case 'right':
        return filteredData.map((e) => e.right).reduce((a, b) => a + b) / filteredData.length;
      case 'net':
        return filteredData.map((e) => e.net).reduce((a, b) => a + b) / filteredData.length;
      default:
        return 0;
    }
  }

  String _trendText(String type) {
    final filteredData = _getFilteredData();
    if (filteredData.length < 2) return "No trend";
    final first = filteredData.first;
    final last = filteredData.last;
    double diff;
    switch (type) {
      case 'left':
        diff = last.left - first.left;
        break;
      case 'right':
        diff = last.right - first.right;
        break;
      case 'net':
        diff = last.net - first.net;
        break;
      default:
        diff = 0;
    }
    if (diff > 5) return "Increasing";
    if (diff < -5) return "Decreasing";
    return "Stable";
  }

  double _calculateImbalanceScore() {
    final filteredData = _getFilteredData();
    if (filteredData.isEmpty) return 0;
    double totalImbalance = 0;
    for (var data in filteredData) {
      totalImbalance += (data.left - data.right).abs();
    }
    return totalImbalance / filteredData.length;
  }

  double _calculateLoadVariability() {
    final filteredData = _getFilteredData();
    if (filteredData.length < 2) return 0;
    double totalChange = 0;
    for (int i = 1; i < filteredData.length; i++) {
      totalChange += (filteredData[i].net - filteredData[i-1].net).abs();
    }
    return totalChange / (filteredData.length - 1);
  }

  Map<String, dynamic> _identifyPressurePeaks() {
    final filteredData = _getFilteredData();
    if (filteredData.isEmpty) return {};
    
    List<PressureData> peaks = [];
    for (int i = 1; i < filteredData.length - 1; i++) {
      if (filteredData[i].net > filteredData[i-1].net && 
          filteredData[i].net > filteredData[i+1].net) {
        peaks.add(filteredData[i]);
      }
    }
    
    return {
      'count': peaks.length,
      'average': peaks.isNotEmpty 
          ? peaks.map((e) => e.net).reduce((a, b) => a + b) / peaks.length 
          : 0,
      'highest': peaks.isNotEmpty 
          ? peaks.map((e) => e.net).reduce((a, b) => a > b ? a : b) 
          : 0,
    };
  }

  String _getLoadDurationAnalysis() {
    final filteredData = _getFilteredData();
    if (filteredData.isEmpty) return "No data";
    final significantLoadThreshold = 20.0;
    int loadedCount = filteredData.where((d) => d.net > significantLoadThreshold).length;
    double loadedPercentage = (loadedCount / filteredData.length) * 100;
    
    if (loadedPercentage > 80) return "Carrying load most of the time";
    if (loadedPercentage > 50) return "Frequent load carrying";
    if (loadedPercentage > 20) return "Occasional load carrying";
    return "Mostly unloaded";
  }

  String _getBalanceAdvice() {
    final imbalanceScore = _calculateImbalanceScore();
    if (imbalanceScore > 15) return "⚠️ Significant imbalance detected! Adjust load distribution.";
    if (imbalanceScore > 8) return "Noticeable imbalance. Consider redistributing weight.";
    return "✅ Good balance maintained.";
  }

  String _getStabilityAdvice() {
    final variability = _calculateLoadVariability();
    if (variability > 10) return "⚠️ Highly variable load. Check for loose items.";
    if (variability > 5) return "Moderate load changes detected.";
    return "✅ Stable load maintained.";
  }

  Widget _buildTimeRangeSelector() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Analysis Time Range:', style: TextStyle(fontWeight: FontWeight.bold)),
          DropdownButton<int>(
            value: _analysisTimeRange,
            items: _timeRangeOptions.map((int value) {
              return DropdownMenuItem<int>(
                value: value,
                child: Text(value <= 24 ? '$value hours' : '${value ~/ 24} days'),
              );
            }).toList(),
            onChanged: (int? newValue) {
              if (newValue != null) {
                setState(() => _analysisTimeRange = newValue);
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(String label, String type, Color color, IconData icon) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        child: Row(
          children: [
            Icon(icon, color: color, size: 32),
            SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(fontWeight: FontWeight.bold)),
                Text('Max: ${_getMax(type).toStringAsFixed(1)}'),
                Text('Min: ${_getMin(type).toStringAsFixed(1)}'),
                Text('Avg: ${_getAvg(type).toStringAsFixed(1)}'),
                Text('Trend: ${_trendText(type)}'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  List<FlSpot> _createSpots(List<PressureData> data, String type) {
    return data.asMap().entries.map((entry) {
      final index = entry.key.toDouble();
      final pressure = entry.value;
      switch (type) {
        case 'left':
          return FlSpot(index, pressure.left);
        case 'right':
          return FlSpot(index, pressure.right);
        case 'net':
          return FlSpot(index, pressure.net);
        default:
          return FlSpot(index, 0);
      }
    }).toList();
  }

  String _formatTimestamp(DateTime dt) {
    return DateFormat('HH:mm').format(dt);
  }

  Widget _buildLineChart() {
    final filteredData = _getFilteredData();
    if (filteredData.isEmpty) return Center(child: Text('No pressure data available.'));
    
    return SizedBox(
      height: 250,
      child: LineChart(
        LineChartData(
          minY: 0,
          maxY: (_getMax('left') > _getMax('right') ? _getMax('left') : _getMax('right')) + 10,
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: (filteredData.length / 5).ceilToDouble(),
                getTitlesWidget: (value, meta) {
                  int index = value.toInt();
                  if (index < 0 || index >= filteredData.length) return Container();
                  return Text(_formatTimestamp(filteredData[index].timestamp), style: TextStyle(fontSize: 10));
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: true, interval: 10),
            ),
          ),
          lineBarsData: [
            LineChartBarData(
              spots: _createSpots(filteredData, 'left'),
              isCurved: true,
              color: Colors.blue,
              barWidth: 3,
              dotData: FlDotData(show: false),
            ),
            LineChartBarData(
              spots: _createSpots(filteredData, 'right'),
              isCurved: true,
              color: Colors.red,
              barWidth: 3,
              dotData: FlDotData(show: false),
            ),
          ],
          gridData: FlGridData(show: true),
          borderData: FlBorderData(show: true),
        ),
      ),
    );
  }

  Widget _buildDistributionChart() {
    final filteredData = _getFilteredData();
    if (filteredData.isEmpty) return Container();
    
    int leftDominant = 0, rightDominant = 0, balanced = 0;
    for (var data in filteredData) {
      final diff = data.left - data.right;
      if (diff.abs() < 5) {
        balanced++;
      } else if (diff > 0) {
        leftDominant++;
      } else {
        rightDominant++;
      }
    }
    
    return SizedBox(
      height: 220,
      child: Card(
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Text('Weight Distribution', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Expanded(
                child: PieChart(
                  PieChartData(
                    sections: [
                      PieChartSectionData(
                        value: leftDominant.toDouble(),
                        color: Colors.blue,
                        title: 'Left\n${((leftDominant/filteredData.length)*100).toStringAsFixed(1)}%',
                        radius: 50,
                        titleStyle: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                      PieChartSectionData(
                        value: rightDominant.toDouble(),
                        color: Colors.red,
                        title: 'Right\n${((rightDominant/filteredData.length)*100).toStringAsFixed(1)}%',
                        radius: 50,
                        titleStyle: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                      PieChartSectionData(
                        value: balanced.toDouble(),
                        color: Colors.green,
                        title: 'Balanced\n${((balanced/filteredData.length)*100).toStringAsFixed(1)}%',
                        radius: 50,
                        titleStyle: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ],
                    sectionsSpace: 0,
                    centerSpaceRadius: 40,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAdvancedMetrics() {
    final filteredData = _getFilteredData();
    if (filteredData.isEmpty) return Container();
    
    final peaks = _identifyPressurePeaks();
    final imbalanceScore = _calculateImbalanceScore();
    final loadVariability = _calculateLoadVariability();
    
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Advanced Metrics', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            _buildMetricRow('Imbalance Score', imbalanceScore.toStringAsFixed(1)),
            _buildMetricRow('Load Variability', loadVariability.toStringAsFixed(1)),
            _buildMetricRow('Pressure Peaks', peaks['count'].toString()),
            _buildMetricRow('Avg Peak Value', peaks['average'].toStringAsFixed(1)),
            _buildMetricRow('Load Duration', _getLoadDurationAnalysis()),
            SizedBox(height: 8),
            Text(_getBalanceAdvice(), style: TextStyle(color: Colors.orange[800])),
            SizedBox(height: 4),
            Text(_getStabilityAdvice(), style: TextStyle(color: Colors.blue[800])),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontWeight: FontWeight.w500)),
          Text(value, style: TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildNetPressureBarChart() {
    final filteredData = _getFilteredData();
    if (filteredData.isEmpty) return Container();
    
    return SizedBox(
      height: 220,
      child: Card(
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              maxY: _getMax('net') + 10,
              barGroups: filteredData.asMap().entries.map((entry) {
                final index = entry.key;
                final data = entry.value;
                return BarChartGroupData(
                  x: index,
                  barRods: [
                    BarChartRodData(
                      toY: data.net,
                      color: data.net > 50 ? Colors.red : (data.net > 20 ? Colors.orange : Colors.green),
                      width: 8,
                    )
                  ],
                );
              }).toList(),
              titlesData: FlTitlesData(
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    interval: (filteredData.length / 5).ceilToDouble(),
                    getTitlesWidget: (value, meta) {
                      int index = value.toInt();
                      if (index < 0 || index >= filteredData.length) return Container();
                      return Text(_formatTimestamp(filteredData[index].timestamp), style: TextStyle(fontSize: 10));
                    },
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: true, interval: 10),
                ),
              ),
              gridData: FlGridData(show: true),
              borderData: FlBorderData(show: true),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pressure Analysis'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _loadPressureHistory,
            tooltip: 'Refresh Data',
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: _pressureHistory.isEmpty
                  ? Center(child: Text('No pressure data available.'))
                  : ListView(
                      children: [
                        _buildTimeRangeSelector(),
                        Text('Pressure Over Time', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        _buildLineChart(),
                        SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(child: _buildSummaryCard('Left Pressure', 'left', Colors.blue, Icons.arrow_left)),
                            SizedBox(width: 8),
                            Expanded(child: _buildSummaryCard('Right Pressure', 'right', Colors.red, Icons.arrow_right)),
                          ],
                        ),
                        SizedBox(height: 8),
                        _buildSummaryCard('Net Pressure', 'net', Colors.green, Icons.swap_horiz),
                        SizedBox(height: 16),
                        Text('Net Pressure Bars', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        _buildNetPressureBarChart(),
                        SizedBox(height: 16),
                        _buildDistributionChart(),
                        SizedBox(height: 16),
                        _buildAdvancedMetrics(),
                      ],
                    ),
            ),
    );
  }
}