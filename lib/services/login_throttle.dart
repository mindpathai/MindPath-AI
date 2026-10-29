/// Locks login for [lockDuration] after [maxAttempts] failures in a row.
///
/// Client-side only, to slow casual guessing; the real backend must
/// enforce its own limits.
class LoginThrottle {
  LoginThrottle({
    this.maxAttempts = 5,
    this.lockDuration = const Duration(seconds: 30),
    DateTime Function()? clock,
  }) : _now = clock ?? DateTime.now;

  final int maxAttempts;
  final Duration lockDuration;
  final DateTime Function() _now;

  int _failures = 0;
  DateTime? _lockedUntil;

  int get failures => _failures;

  /// Time left on the lock, or [Duration.zero] when unlocked.
  /// Clears the lock and failure count once it has expired.
  Duration get remaining {
    final until = _lockedUntil;
    if (until == null) return Duration.zero;
    final left = until.difference(_now());
    if (left > Duration.zero) return left;
    reset();
    return Duration.zero;
  }

  bool get isLocked => remaining > Duration.zero;

  void recordFailure() {
    _failures++;
    if (_failures >= maxAttempts) _lockedUntil = _now().add(lockDuration);
  }

  void reset() {
    _failures = 0;
    _lockedUntil = null;
  }
}
