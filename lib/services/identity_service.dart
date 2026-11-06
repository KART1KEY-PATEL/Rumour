import 'dart:convert';
import 'dart:math';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/room_identity.dart';
import '../utils/word_lists.dart';

class IdentityService {
  IdentityService({http.Client? httpClient, SharedPreferences? prefs})
    : _httpClient = httpClient ?? http.Client(),
      _prefs = prefs;

  final http.Client _httpClient;
  SharedPreferences? _prefs;

  Future<SharedPreferences> get _preferences async =>
      _prefs ??= await SharedPreferences.getInstance();

  String _cacheKey(String roomCode) => 'identity_$roomCode';

  Future<RoomIdentity?> getCachedIdentity(String roomCode) async {
    final prefs = await _preferences;
    final raw = prefs.getString(_cacheKey(roomCode));
    if (raw == null) return null;
    try {
      return RoomIdentity.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  Future<void> _cacheIdentity(RoomIdentity identity) async {
    final prefs = await _preferences;
    await prefs.setString(
      _cacheKey(identity.roomCode),
      jsonEncode(identity.toJson()),
    );
  }

  Future<RoomIdentity> createIdentity(String roomCode) async {
    final hash = await _fetchEntropyHash();
    final adjective = kAdjectives[hash % kAdjectives.length];
    final animal = kAnimals[(hash ~/ kAdjectives.length) % kAnimals.length];
    final identity = RoomIdentity(
      roomCode: roomCode,
      displayName: '$adjective $animal',
    );
    await _cacheIdentity(identity);
    return identity;
  }

  Future<RoomIdentity> getOrCreateIdentity(String roomCode) async {
    final cached = await getCachedIdentity(roomCode);
    if (cached != null) return cached;
    return createIdentity(roomCode);
  }

  Future<int> _fetchEntropyHash() async {
    try {
      final response = await _httpClient
          .get(Uri.parse('https://randomuser.me/api/'))
          .timeout(const Duration(seconds: 6));
      if (response.statusCode == 200) {
        final body = jsonDecode(response.body) as Map<String, dynamic>;
        final results = body['results'] as List<dynamic>;
        final uuid = (results.first as Map<String, dynamic>)['login']['uuid']
            as String;
        return _fnv1aHash(uuid);
      }
    } catch (_) {}
    return _fnv1aHash(
      '${DateTime.now().microsecondsSinceEpoch}-${Random().nextInt(1 << 32)}',
    );
  }

  int _fnv1aHash(String input) {
    const fnvPrime = 0x01000193;
    var hash = 0x811c9dc5;
    for (final codeUnit in input.codeUnits) {
      hash ^= codeUnit;
      hash = (hash * fnvPrime) & 0xFFFFFFFF;
    }
    return hash;
  }
}
