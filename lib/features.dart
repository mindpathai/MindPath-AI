/// Parts of the app that stay out of the UI until they work. Their code is
/// kept in place; flip a flag when its module ships.
abstract final class Features {
  /// The real assessment engine (Module 4).
  static const bool assessmentEngine = false;

  /// Exporting a report (Module 9).
  static const bool reportExport = false;

  /// Therapy programs (Module 10).
  static const bool therapy = false;

  /// Saved check-ins and the progress built on them (Module 11).
  static const bool progress = false;

  /// History and the chatbot (Module 11).
  static const bool historyAndChat = false;
}
