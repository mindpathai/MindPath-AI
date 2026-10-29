import 'package:flutter/material.dart';

import 'package:mindpath_ai/widgets/line_icon.dart';
import 'package:mindpath_ai/widgets/placeholder_screen.dart';

class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlaceholderScreen(
      title: 'Progress',
      glyph: LineGlyphs.progress,
    );
  }
}
