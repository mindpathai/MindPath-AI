import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:mindpath_ai/routes/app_router.dart';
import 'package:mindpath_ai/services/auth_scope.dart';
import 'package:mindpath_ai/widgets/app_buttons.dart';
import 'package:mindpath_ai/widgets/line_icon.dart';
import 'package:mindpath_ai/widgets/placeholder_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PlaceholderScreen(
      title: 'Profile',
      glyph: LineGlyphs.you,
      actions: [
        PillButton(
          label: 'Sign out',
          style: PillStyle.ghost,
          onPressed: () async {
            await AuthScope.read(context).signOut();
            if (context.mounted) context.go(AppRoutes.welcome);
          },
        ),
      ],
    );
  }
}
