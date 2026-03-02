import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config.dart';

/// A single chat message for the DeepSeek API.
class ChatMessage {
  final String role;    // 'system' | 'user' | 'assistant'
  final String content;

  const ChatMessage({required this.role, required this.content});

  Map<String, String> toJson() => {'role': role, 'content': content};
}

/// Wraps the DeepSeek Chat Completions API.
class DeepSeekService {
  static const _baseUrl = 'https://api.deepseek.com/chat/completions';
  static const _model   = 'deepseek-chat';

  /// Sends a conversation history (with system prompt prepended) to DeepSeek
  /// and returns the assistant's reply text.
  ///
  /// Throws a [DeepSeekException] on API or network errors.
  static Future<String> chat({
    required List<ChatMessage> history,
    required String systemPrompt,
  }) async {

    final messages = [
      ChatMessage(role: 'system', content: systemPrompt),
      ...history,
    ];

    final response = await http.post(
      Uri.parse(_baseUrl),
      headers: {
        'Content-Type':  'application/json',
        'Authorization': 'Bearer $deepSeekApiKey',
      },
      body: jsonEncode({
        'model':       _model,
        'messages':    messages.map((m) => m.toJson()).toList(),
        'max_tokens':  512,
        'temperature': 0.8,
      }),
    );

    if (response.statusCode != 200) {
      throw DeepSeekException(
        'HTTP ${response.statusCode}: ${response.body}',
      );
    }

    final data    = jsonDecode(response.body) as Map<String, dynamic>;
    final choices = data['choices'] as List<dynamic>;
    if (choices.isEmpty) throw const DeepSeekException('Empty choices in response.');

    final content = (choices[0] as Map<String, dynamic>)['message']
        ['content'] as String;
    return content.trim();
  }
}

class DeepSeekException implements Exception {
  final String message;
  const DeepSeekException(this.message);

  @override
  String toString() => 'DeepSeekException: $message';
}
