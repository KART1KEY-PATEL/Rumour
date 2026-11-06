import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:pinput/pinput.dart';
import 'package:rumour/app/theme.dart';
import 'package:rumour/screens/join_room_screen.dart';
import 'package:rumour/utils/date_formatter.dart';
import 'package:rumour/utils/room_code.dart';

void main() {
  group('room codes', () {
    test('generateRoomCode produces valid, correctly-sized codes', () {
      final random = Random(42);
      for (var i = 0; i < 50; i++) {
        final code = generateRoomCode(random);
        expect(code.length, kRoomCodeLength);
        expect(isValidRoomCode(code), isTrue);
      }
    });

    test('normalizeRoomCode trims and upper-cases input', () {
      expect(normalizeRoomCode('  ab12cd  '), 'AB12CD');
    });

    test('isValidRoomCode rejects ambiguous characters and wrong length', () {
      expect(isValidRoomCode('ABC12'), isFalse);
      expect(isValidRoomCode('ABCDE0'), isFalse);
      expect(isValidRoomCode('ABCDEF'), isTrue);
    });
  });

  group('date formatting', () {
    test('formatDateSeparator labels today and yesterday', () {
      final now = DateTime.now();
      expect(formatDateSeparator(now), 'Today');
      expect(
        formatDateSeparator(now.subtract(const Duration(days: 1))),
        'Yesterday',
      );
    });

    test('isSameDay compares calendar days regardless of time', () {
      final a = DateTime(2026, 1, 5, 23, 59);
      final b = DateTime(2026, 1, 5, 0, 1);
      final c = DateTime(2026, 1, 6, 0, 1);
      expect(isSameDay(a, b), isTrue);
      expect(isSameDay(a, c), isFalse);
    });
  });

  testWidgets('JoinRoomScreen renders title, subtitle and code input', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(theme: buildDarkTheme(), home: const JoinRoomScreen()),
    );

    expect(find.text('Join A Room'), findsOneWidget);
    expect(
      find.text('Enter the code to join the anon chat room'),
      findsOneWidget,
    );
    expect(find.byType(Pinput), findsOneWidget);
  });
}
