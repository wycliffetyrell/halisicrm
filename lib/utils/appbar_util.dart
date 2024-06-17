import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Add intl package for date formatting

final DateTime now = DateTime.now();
final String formattedDate = DateFormat('EEEE, MMMM d, yyyy').format(now);
final String greeting = _getGreeting(now);
final String emoji = _getEmoji(now);
final Color emojiColor = _getEmojiColor(now);

String _getGreeting(DateTime now) {
  final int hour = now.hour;
  if (hour < 12) {
    return 'Good morning';
  } else if (hour < 18) {
    return 'Good afternoon';
  } else {
    return 'Good evening';
  }
}

String _getEmoji(DateTime now) {
  final int hour = now.hour;
  if (hour < 12) {
    return '☀️'; // Sun emoji
  } else if (hour < 18) {
    return '🌤️'; // Sun with cloud emoji
  } else {
    return '🌙'; // Moon emoji
  }
}

Color _getEmojiColor(DateTime now) {
  final int hour = now.hour;
  if (hour < 12) {
    return Colors.orange; // Orange color for morning
  } else if (hour < 18) {
    return Colors.yellow; // Yellow color for afternoon
  } else {
    return Colors.grey; // Grey color for evening
  }
}
