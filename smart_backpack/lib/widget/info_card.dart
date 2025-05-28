import 'package:flutter/material.dart';

class InfoCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color iconColor;
  final Color cardColor;
  final Widget? widget;
  final TextStyle textStyle; // ✅ Added textStyle parameter

  const InfoCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.iconColor,
    this.cardColor = Colors.white,
    this.widget,
    this.textStyle = const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black), // ✅ Default style
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      color: cardColor,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: iconColor, size: 24),
            const SizedBox(height: 8),
            Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
            if (widget != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: widget!,
              ),
            const Spacer(),
            Align(
              alignment: Alignment.bottomRight,
              child: Text(value, style: textStyle), // ✅ Uses customizable text style
            ),
          ],
        ),
      ),
    );
  }
}