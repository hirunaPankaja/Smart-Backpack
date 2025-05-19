import 'package:flutter/material.dart';

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
              Text(
                widget.value,
                style: const TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(widget.title, style: TextStyle(color: Colors.grey[600], fontSize: 14)),
            ],
          ),
        );
      },
    );
  }
}
