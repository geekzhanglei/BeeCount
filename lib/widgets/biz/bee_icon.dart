import 'package:flutter/material.dart';

/// Compatibility wrapper for existing branded icon placements.
/// The custom app identity is shared across the app instead of showing the
/// upstream bee mark in secondary screens and generated posters.
class BeeIcon extends StatelessWidget {
  final double size;

  const BeeIcon({super.key, required Color color, this.size = 256});

  @override
  Widget build(BuildContext context) => ClipRRect(
        borderRadius: BorderRadius.circular(size * 0.2),
        child: Image.asset(
          'assets/brand/app_icon.png',
          width: size,
          height: size,
          fit: BoxFit.cover,
        ),
      );
}
