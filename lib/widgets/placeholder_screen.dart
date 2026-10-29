import 'package:flutter/material.dart';

import 'package:mindpath_ai/theme/app_tokens.dart';
import 'package:mindpath_ai/theme/app_typography.dart';
import 'package:mindpath_ai/widgets/ambient_background.dart';
import 'package:mindpath_ai/widgets/icon_badge.dart';
import 'package:mindpath_ai/widgets/layout.dart';
import 'package:mindpath_ai/widgets/line_icon.dart';

/// Temporary tab screen: a badge, the title, "Coming soon" and actions.
class PlaceholderScreen extends StatelessWidget {
  const PlaceholderScreen({
    super.key,
    required this.title,
    required this.glyph,
    this.actions = const [],
  });

  final String title;
  final LineGlyph glyph;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    final canPop = ModalRoute.of(context)?.canPop ?? false;
    return Scaffold(
      body: AmbientBackground(
        child: SafeArea(
          child: ContentWidth(
            child: Column(
              children: [
                if (canPop)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpace.s20,
                    ),
                    child: ScreenTopBar(
                      title: title,
                      onBack: () => Navigator.of(context).pop(),
                    ),
                  ),
                Expanded(child: _body()),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _body() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpace.s20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconBadge(glyph),
            const SizedBox(height: AppSpace.s16),
            Text(title, style: AppTypography.heading),
            const SizedBox(height: AppSpace.s4),
            Text('Coming soon', style: AppTypography.caption),
            for (final action in actions) ...[
              const SizedBox(height: AppSpace.s24),
              action,
            ],
          ],
        ),
      ),
    );
  }
}
