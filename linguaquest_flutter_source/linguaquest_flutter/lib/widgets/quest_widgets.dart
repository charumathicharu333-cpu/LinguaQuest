import 'package:flutter/material.dart';

import '../app/theme.dart';

class QuestCard extends StatelessWidget {
  const QuestCard(
      {super.key,
      required this.child,
      this.color = Colors.white,
      this.padding = const EdgeInsets.all(18),
      this.onTap});
  final Widget child;
  final Color color;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final content = Container(
      width: double.infinity,
      padding: padding,
      decoration:
          BoxDecoration(color: color, borderRadius: BorderRadius.circular(24)),
      child: child,
    );
    return onTap == null
        ? content
        : InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(24),
            child: content);
  }
}

class ScreenColumn extends StatelessWidget {
  const ScreenColumn(
      {super.key,
      required this.children,
      this.padding = const EdgeInsets.fromLTRB(20, 12, 20, 26)});
  final List<Widget> children;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) => SafeArea(
        top: true,
        child: ListView(padding: padding, children: [
          for (var i = 0; i < children.length; i++) ...[
            if (i > 0) const SizedBox(height: 16),
            children[i]
          ]
        ]),
      );
}

class QuestProgress extends StatelessWidget {
  const QuestProgress(
      {super.key,
      required this.value,
      this.color = QuestColors.teal,
      this.height = 9});
  final double value;
  final Color color;
  final double height;

  @override
  Widget build(BuildContext context) => ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: LinearProgressIndicator(
            value: value.clamp(0, 1).toDouble(),
            minHeight: height,
            backgroundColor: const Color(0xFFE7ECE9),
            color: color),
      );
}

class OfflinePill extends StatelessWidget {
  const OfflinePill({super.key});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
        decoration: BoxDecoration(
            color: QuestColors.mint, borderRadius: BorderRadius.circular(30)),
        child: const Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.wifi_off_rounded, size: 14, color: QuestColors.teal),
          SizedBox(width: 5),
          Text('READY OFFLINE',
              style: TextStyle(
                  fontSize: 10,
                  letterSpacing: .5,
                  fontWeight: FontWeight.w900,
                  color: QuestColors.teal))
        ]),
      );
}

class RoundIcon extends StatelessWidget {
  const RoundIcon(
      {super.key,
      required this.icon,
      this.background = QuestColors.mint,
      this.size = 48});
  final IconData icon;
  final Color background;
  final double size;

  @override
  Widget build(BuildContext context) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
            color: background, borderRadius: BorderRadius.circular(size / 2)),
        child: Icon(icon, color: QuestColors.ink, size: 22),
      );
}

class GameButton extends StatelessWidget {
  const GameButton(
      {super.key, required this.label, required this.onPressed, this.icon});
  final String label;
  final VoidCallback onPressed;
  final IconData? icon;

  @override
  Widget build(BuildContext context) => SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: onPressed,
          icon: Icon(icon ?? Icons.arrow_forward_rounded),
          label: Text(label),
        ),
      );
}

void showQuestMessage(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating));
}
