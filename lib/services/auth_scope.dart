import 'package:flutter/widgets.dart';

import 'package:mindpath_ai/services/auth_service.dart';

/// Makes the [AuthService] available to the widget tree.
/// Dependents rebuild when the signed-in user changes.
class AuthScope extends InheritedNotifier<AuthService> {
  const AuthScope({
    super.key,
    required AuthService service,
    required super.child,
  }) : super(notifier: service);

  static AuthService of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AuthScope>();
    assert(scope != null, 'No AuthScope found above this widget');
    return scope!.notifier!;
  }

  /// Like [of] but without rebuilding on changes. Use in callbacks.
  static AuthService read(BuildContext context) {
    final scope = context.getInheritedWidgetOfExactType<AuthScope>();
    assert(scope != null, 'No AuthScope found above this widget');
    return scope!.notifier!;
  }
}
