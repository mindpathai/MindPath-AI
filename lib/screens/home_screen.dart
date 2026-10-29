import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:mindpath_ai/routes/app_router.dart';
import 'package:mindpath_ai/services/auth_scope.dart';
import 'package:mindpath_ai/theme/app_tokens.dart';
import 'package:mindpath_ai/widgets/ambient_background.dart';
import 'package:mindpath_ai/widgets/dashboard_cards.dart';
import 'package:mindpath_ai/widgets/icon_badge.dart';
import 'package:mindpath_ai/widgets/layout.dart';
import 'package:mindpath_ai/widgets/line_icon.dart';
import 'package:mindpath_ai/widgets/mood_strip.dart';

/// Home tab: the user's dashboard.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = AuthScope.of(context).currentUser;
    // Includes the floating nav bar's height (the shell extends the body).
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return Scaffold(
      body: AmbientBackground(
        clayTop: 420,
        child: SafeArea(
          bottom: false,
          child: ContentWidth(
            child: ListView(
              padding: EdgeInsets.fromLTRB(
                AppSpace.s20,
                0,
                AppSpace.s20,
                bottomInset + AppSpace.s16,
              ),
              children: [
                HomeHeader(
                  firstName: user?.firstName ?? 'there',
                  now: DateTime.now(),
                  onSos: () => context.push(AppRoutes.safety),
                ),
                const SizedBox(height: AppSpace.s16),
                const MoodCard(child: MoodStrip()),
                const SizedBox(height: AppSpace.s16),
                CheckInHero(onStart: () => context.go(AppRoutes.assessment)),
                const SizedBox(height: AppSpace.s16),
                IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        child: QuickActionCard(
                          glyph: LineGlyphs.breathe,
                          tone: Tone.pine,
                          title: 'Breathe',
                          caption: '4 · 7 · 8, two minutes',
                          onTap: () {}, // Placeholder until Therapy exists.
                        ),
                      ),
                      const SizedBox(width: AppSpace.s12),
                      Expanded(
                        child: QuickActionCard(
                          glyph: LineGlyphs.ground,
                          tone: Tone.sage,
                          title: 'Ground',
                          caption: '5 · 4 · 3 · 2 · 1 senses',
                          onTap: () {}, // Placeholder until Therapy exists.
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpace.s16),
                // No check-in history is stored yet.
                const WellnessFingerprintCard(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
