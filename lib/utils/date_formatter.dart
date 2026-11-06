import 'package:intl/intl.dart';

String formatMessageTime(DateTime? time) {
  if (time == null) return '';
  return DateFormat('HH:mm').format(time.toLocal());
}

String formatDateSeparator(DateTime date) {
  final local = date.toLocal();
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final day = DateTime(local.year, local.month, local.day);
  final difference = today.difference(day).inDays;

  if (difference == 0) return 'Today';
  if (difference == 1) return 'Yesterday';
  return DateFormat('MMM d, yyyy').format(local);
}

bool isSameDay(DateTime a, DateTime b) {
  final la = a.toLocal();
  final lb = b.toLocal();
  return la.year == lb.year && la.month == lb.month && la.day == lb.day;
}
