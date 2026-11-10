import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:mindpath_ai/features.dart';
import 'package:mindpath_ai/routes/app_router.dart';
import 'package:mindpath_ai/services/auth_scope.dart';
import 'package:mindpath_ai/theme/app_tokens.dart';
import 'package:mindpath_ai/widgets/ambient_background.dart';
import 'package:mindpath_ai/widgets/dashboard_cards.dart';
import 'package:mindpath_ai/widgets/layout.dart';
import 'package:mindpath_ai/widgets/mood_strip.dart';

/// Home tab: the user's dashboard.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Not saved yet: it lasts until the app closes.
  int? _mood;

  /// The support options are hidden until an answer makes them relevant.
  /// Assessment results join this check once scoring exists (Module 4).
  bool get _showSupport {
    final mood = _mood;
    return mood != null && MoodStrip.isLow(mood);
  }

  @override
  Widget build(BuildContext context) {
    final user = AuthScope.of(context).currentUser;
    // Includes the floating nav bar's height (the shell extends the body).
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return Scaffold(
      body: AmbientBackground(
        sageTop: 420,
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
                const SizedBox(height: AppSpace.s24),
                StepLabel(
                  number: 1,
                  label: 'Mood check-in',
                  active: _mood == null,
                ),
                const SizedBox(height: AppSpace.s9),
                MoodCard(
                  child: MoodStrip(
                    selected: _mood,
                    onSelected: (mood) => setState(() => _mood = mood),
                  ),
                ),
                AnimatedSize(
                  duration: AppMotion.of(context),
                  curve: AppMotion.curve,
                  child: _showSupport
                      ? const Padding(
                          padding: EdgeInsets.only(top: AppSpace.s16),
                          child: SupportOptions(),
                        )
                      : const SizedBox(width: double.infinity),
                ),
                const SizedBox(height: AppSpace.s30),
                StepLabel(number: 2, label: 'Questions', active: _mood != null),
                const SizedBox(height: AppSpace.s9),
                // Never locked: the mood step guides, it does not block.
                CheckInHero(
                  active: _mood != null,
                  onStart: () => context.go(AppRoutes.assessment),
                ),
                // Hidden: no check-ins are saved yet, so it could only ever
                // show zero. Unlocked by saved check-ins (Module 11).
                if (Features.progress) ...[
                  const SizedBox(height: AppSpace.s30),
                  const StepLabel(
                    number: 3,
                    label: 'Your progress',
                    active: false,
                  ),
                  const SizedBox(height: AppSpace.s9),
                  const WellnessFingerprintCard(),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
