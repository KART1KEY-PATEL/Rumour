import 'dart:math';

const String _kRoomCodeAlphabet = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
const int kRoomCodeLength = 6;

String generateRoomCode([Random? random]) {
  final rng = random ?? Random.secure();
  return List.generate(
    kRoomCodeLength,
    (_) => _kRoomCodeAlphabet[rng.nextInt(_kRoomCodeAlphabet.length)],
  ).join();
}

String normalizeRoomCode(String input) =>
    input.trim().toUpperCase().replaceAll(RegExp(r'\s'), '');

bool isValidRoomCode(String code) =>
    code.length == kRoomCodeLength &&
    code.split('').every(_kRoomCodeAlphabet.contains);
