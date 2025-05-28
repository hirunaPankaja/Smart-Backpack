import 'package:flutter/material.dart';

class InfoCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color iconColor;
  final Color cardColor; // ✅ Added card background color
  final Widget? widget;

  const InfoCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.iconColor,
    this.cardColor = Colors.white, // ✅ Default color
    this.widget,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      color: cardColor, // ✅ Dynamic color change
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: iconColor, size: 24),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            if (widget != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: widget!,
              ),
            const Spacer(),
            Align(
              alignment: Alignment.bottomRight,
              child: Text(
                value,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey),
              ),
            ),
          ],
        ),
      ),
    );
  }
}