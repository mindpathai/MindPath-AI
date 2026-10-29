import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:mindpath_ai/widgets/floating_nav_bar.dart';
import 'package:mindpath_ai/widgets/line_icon.dart';

/// Hosts the tabs under the floating navigation bar.
///
/// System Back on any tab other than Home returns to Home, as Material
/// expects; only Back on Home leaves the app.
class HomeShell extends StatelessWidget {
  const HomeShell({super.key, required this.shell});

  final StatefulNavigationShell shell;

  static const List<NavItem> _tabs = [
    (glyph: LineGlyphs.home, label: 'Home'),
    (glyph: LineGlyphs.checkIn, label: 'Check-in'),
    (glyph: LineGlyphs.therapy, label: 'Therapy'),
    (glyph: LineGlyphs.progress, label: 'Progress'),
    (glyph: LineGlyphs.you, label: 'You'),
  ];

  @override
  Widget build(BuildContext context) {
    final onHome = shell.currentIndex == 0;
    return PopScope(
      canPop: onHome,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) shell.goBranch(0);
      },
      child: Scaffold(
        extendBody: true,
        body: shell,
        bottomNavigationBar: FloatingNavBar(
          items: _tabs,
          selectedIndex: shell.currentIndex,
          onSelected: (index) => shell.goBranch(
            index,
            initialLocation: index == shell.currentIndex,
          ),
        ),
      ),
    );
  }
}
