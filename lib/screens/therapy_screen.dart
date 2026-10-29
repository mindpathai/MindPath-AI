import 'package:flutter/material.dart';

import 'package:mindpath_ai/widgets/line_icon.dart';
import 'package:mindpath_ai/widgets/placeholder_screen.dart';

class TherapyScreen extends StatelessWidget {
  const TherapyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlaceholderScreen(title: 'Therapy', glyph: LineGlyphs.therapy);
  }
}
