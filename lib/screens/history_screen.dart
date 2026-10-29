import 'package:flutter/material.dart';

import 'package:mindpath_ai/widgets/line_icon.dart';
import 'package:mindpath_ai/widgets/placeholder_screen.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlaceholderScreen(
      title: 'History',
      glyph: LineGlyphs.progress,
    );
  }
}
