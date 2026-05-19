/// Client-side rules aligned with backend [MessageContentRules] (max 200 chars).
class MessageContent {
  MessageContent._();

  static const int maxLength = 200;

  /// Returns an error message when [raw] cannot be sent; null when valid.
  static String? validateForSend(String? raw) {
    final trimmed = raw?.trim() ?? '';
    if (trimmed.isEmpty) {
      return 'Message cannot be empty.';
    }
    if (trimmed.length > maxLength) {
      return 'Message cannot exceed $maxLength characters.';
    }
    return null;
  }

  /// Trim before sending to the API / SignalR.
  static String prepareForSend(String raw) => raw.trim();

  /// Safe text for UI: strips control characters and caps length.
  static String forDisplay(String? raw) {
    if (raw == null || raw.isEmpty) return '';

    var text = raw.replaceAll(RegExp(r'[\x00-\x08\x0B\x0C\x0E-\x1F\x7F]'), '');

    if (text.length > maxLength) {
      return '${text.substring(0, maxLength)}…';
    }
    return text;
  }
}
