import 'dart:math';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Thin wrapper around Supabase for couple mode sessions.
///
/// DB table: couple_sessions
///   id          uuid primary key default gen_random_uuid()
///   invite_code text unique not null
///   entry_type  text not null          -- 'partner' | 'self'
///   answers_a   jsonb                  -- first person's answers
///   answers_b   jsonb                  -- second person's answers
///   created_at  timestamptz default now()
class SupabaseService {
  static final _client = Supabase.instance.client;

  /// Generate a random 6-character uppercase invite code.
  static String _generateCode() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final rng = Random.secure();
    return List.generate(6, (_) => chars[rng.nextInt(chars.length)]).join();
  }

  /// Create a new couple session. Returns the invite code.
  static Future<String> createSession({required String entryType}) async {
    final code = _generateCode();
    await _client.from('couple_sessions').insert({
      'invite_code': code,
      'entry_type': entryType,
    });
    return code;
  }

  /// Join an existing session by invite code.
  /// Returns the session row or throws if not found.
  static Future<Map<String, dynamic>> joinSession(String code) async {
    final rows = await _client
        .from('couple_sessions')
        .select()
        .eq('invite_code', code.toUpperCase())
        .limit(1);

    if (rows.isEmpty) {
      throw Exception('Session not found. Check the invite code and try again.');
    }
    return rows.first;
  }

  /// Save answers for person A (session creator).
  static Future<void> saveAnswersA({
    required String sessionId,
    required Map<String, bool> answers,
  }) async {
    await _client
        .from('couple_sessions')
        .update({'answers_a': answers})
        .eq('id', sessionId);
  }

  /// Save answers for person B (invited partner).
  static Future<void> saveAnswersB({
    required String sessionId,
    required Map<String, bool> answers,
  }) async {
    await _client
        .from('couple_sessions')
        .update({'answers_b': answers})
        .eq('id', sessionId);
  }

  /// Subscribe to a session for real-time updates.
  /// Calls [onUpdate] whenever the row changes.
  static RealtimeChannel subscribeToSession({
    required String sessionId,
    required void Function(Map<String, dynamic> payload) onUpdate,
  }) {
    return _client
        .channel('session:$sessionId')
        .onPostgresChanges(
          event: PostgresChangeEvent.update,
          schema: 'public',
          table: 'couple_sessions',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'id',
            value: sessionId,
          ),
          callback: (payload) => onUpdate(payload.newRecord),
        )
        .subscribe();
  }
}
