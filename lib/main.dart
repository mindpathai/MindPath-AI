import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:mindpath_ai/app.dart';
import 'package:mindpath_ai/firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Fonts ship in assets/google_fonts; never fetch them over the network.
  GoogleFonts.config.allowRuntimeFetching = false;
  _registerFontLicences();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MindPathApp());
}

/// The bundled fonts are under the SIL Open Font License, which must ship
/// with them. Shown in Flutter's licence page.
void _registerFontLicences() {
  const fonts = {
    'Fraunces': 'assets/google_fonts/OFL-Fraunces.txt',
    'Hanken Grotesk': 'assets/google_fonts/OFL-HankenGrotesk.txt',
  };
  LicenseRegistry.addLicense(() async* {
    for (final MapEntry(key: name, value: path) in fonts.entries) {
      yield LicenseEntryWithLineBreaks([name], await rootBundle.loadString(path));
    }
  });
}
