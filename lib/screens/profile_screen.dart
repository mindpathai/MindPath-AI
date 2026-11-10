import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:mindpath_ai/routes/app_router.dart';
import 'package:mindpath_ai/services/auth_scope.dart';
import 'package:mindpath_ai/theme/app_colors.dart';
import 'package:mindpath_ai/theme/app_tokens.dart';
import 'package:mindpath_ai/theme/app_typography.dart';
import 'package:mindpath_ai/widgets/ambient_background.dart';
import 'package:mindpath_ai/widgets/app_buttons.dart';
import 'package:mindpath_ai/widgets/app_card.dart';
import 'package:mindpath_ai/widgets/form_message.dart';
import 'package:mindpath_ai/widgets/layout.dart';

/// "You" tab: who is signed in, and Log out.
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _loading = false;
  String? _error;

  Future<void> _logOut() async {
    // A second tap can land before the rebuild that disables the button.
    if (_loading) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await AuthScope.read(context).signOut();
      if (mounted) context.go(AppRoutes.welcome);
    } catch (_) {
      if (mounted) {
        setState(() {
          _loading = false;
          _error = 'Could not log out. Please try again.';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = AuthScope.of(context).currentUser;
    final name = user?.name.trim() ?? '';
    final email = user?.email ?? '';
    // Includes the floating nav bar's height (the shell extends the body).
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return Scaffold(
      body: AmbientBackground(
        child: SafeArea(
          bottom: false,
          child: ContentWidth(
            child: ScreenScroll(
              bottomInset: bottomInset,
              footer: const Padding(
                padding: EdgeInsets.only(
                  top: AppSpace.s24,
                  bottom: AppSpace.s26,
                ),
                child: NoteText(kNoDiagnosisNote),
              ),
              children: [
                // No Back: this is a tab, and the tab bar is the way out.
                const ScreenTopBar(title: 'Your account'),
                const SizedBox(height: AppSpace.s18),
                AppCard(
                  child: Row(
                    children: [
                      ExcludeSemantics(
                        child: Container(
                          width: AppSizes.avatar,
                          height: AppSizes.avatar,
                          alignment: Alignment.center,
                          decoration: const BoxDecoration(
                            color: AppColors.pineSoft,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            name.isEmpty ? '?' : name[0].toUpperCase(),
                            style: AppTypography.strong.copyWith(
                              color: AppColors.pine,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpace.s14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              name.isEmpty ? 'Your name' : name,
                              style: AppTypography.strong,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: AppSpace.s3),
                            Text(
                              email,
                              style: AppTypography.small.copyWith(
                                color: AppColors.ink2,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpace.s14),
                const NoteText(
                  'Your details are private. Only you can see them.',
                ),
                FormMessage(_error),
                const SizedBox(height: AppSpace.s24),
                PillButton(
                  label: 'Log out',
                  style: PillStyle.ghost,
                  expand: true,
                  large: true,
                  loading: _loading,
                  padding: const EdgeInsets.symmetric(vertical: AppSpace.s15),
                  onPressed: _logOut,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
