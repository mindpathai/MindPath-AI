/// Small date/greeting helpers, kept free of the intl package.
library;

const List<String> _weekdays = [
  'Monday',
  'Tuesday',
  'Wednesday',
  'Thursday',
  'Friday',
  'Saturday',
  'Sunday',
];

const List<String> _months = [
  'January',
  'February',
  'March',
  'April',
  'May',
  'June',
  'July',
  'August',
  'September',
  'October',
  'November',
  'December',
];

/// e.g. "Saturday, 24 October".
String longDate(DateTime d) =>
    '${_weekdays[d.weekday - 1]}, ${d.day} ${_months[d.month - 1]}';

String greetingFor(DateTime d) {
  if (d.hour < 12) return 'Good morning';
  if (d.hour < 17) return 'Good afternoon';
  return 'Good evening';
}
