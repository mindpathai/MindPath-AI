import 'package:flutter/material.dart';

import 'package:mindpath_ai/widgets/line_icon.dart';
import 'package:mindpath_ai/widgets/placeholder_screen.dart';

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlaceholderScreen(title: 'Chat', glyph: LineGlyphs.you);
  }
}
