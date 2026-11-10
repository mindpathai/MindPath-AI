import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:mindpath_ai/features.dart';
import 'package:mindpath_ai/widgets/floating_nav_bar.dart';
import 'package:mindpath_ai/widgets/line_icon.dart';

/// Hosts the tabs under the floating navigation bar.
///
/// System Back on any tab other than Home returns to Home, as Material
/// expects; only Back on Home leaves the app.
class HomeShell extends StatelessWidget {
  const HomeShell({super.key, required this.shell});

  final StatefulNavigationShell shell;

  /// The visible tabs, each with the index of its shell branch.
  static const List<({int branch, NavItem item})> _tabs = [
    (branch: 0, item: (glyph: LineGlyphs.home, label: 'Home')),
    (branch: 1, item: (glyph: LineGlyphs.questions, label: 'Questions')),
    // Hidden: only a "Coming soon" page. Unlocked by Therapy (Module 10).
    if (Features.therapy)
      (branch: 2, item: (glyph: LineGlyphs.therapy, label: 'Therapy')),
    // Hidden: only a "Coming soon" page. Unlocked by Progress (Module 11).
    if (Features.progress)
      (branch: 3, item: (glyph: LineGlyphs.progress, label: 'Progress')),
    (branch: 4, item: (glyph: LineGlyphs.you, label: 'You')),
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
          items: [for (final tab in _tabs) tab.item],
          selectedIndex: _tabs.indexWhere(
            (tab) => tab.branch == shell.currentIndex,
          ),
          onSelected: (index) {
            final branch = _tabs[index].branch;
            shell.goBranch(
              branch,
              initialLocation: branch == shell.currentIndex,
            );
          },
        ),
      ),
    );
  }
}
