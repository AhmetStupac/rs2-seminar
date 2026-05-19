import 'dart:convert';

/// Centralized parser for all API error response bodies.
///
/// Handles every shape the backend can return:
///   • `{ "message": "..." }`          — all controllers + BanMiddleware + ExceptionFilter
///   • `{ "title": "..." }`            — ASP.NET ModelState / ProblemDetails
///   • `{ "errors": { "f": ["msg"] } }` — ASP.NET ModelState validation errors
///   • Plain string body               — some BadRequest overloads
class ApiError {
  ApiError._();

  /// Converts a raw HTTP response body into a human-readable message.
  ///
  /// [statusCode] is optional — when provided, a friendlier fallback is used
  /// for well-known codes if the body carries no useful text.
  static String fromBody(
    String body, {
    int? statusCode,
    String? fallback,
  }) {
    final defaultFallback = fallback ?? fallbackForStatus(statusCode);

    if (body.isEmpty) return defaultFallback;

    try {
      final data = jsonDecode(body);

      if (data is Map) {
        // Priority 1: explicit message field (most common)
        final msg = data['message'];
        if (msg is String && msg.isNotEmpty) return msg;

        // Priority 2: ASP.NET validation errors dict
        // Shape: { "errors": { "Field": ["Error 1", "Error 2"] } }
        final errors = data['errors'];
        if (errors is Map && errors.isNotEmpty) {
          final joined = errors.values
              .expand(
                (v) => v is List
                    ? v.map((e) => e.toString())
                    : [v.toString()],
              )
              .where((s) => s.isNotEmpty)
              .join(' ');
          if (joined.isNotEmpty) return joined;
        }

        // Priority 3: ASP.NET ProblemDetails title
        final title = data['title'];
        if (title is String && title.isNotEmpty) return title;

        // Priority 4: generic error field
        final error = data['error'];
        if (error is String && error.isNotEmpty) return error;
      }

      // Plain string body
      if (data is String && data.isNotEmpty) return data;
    } catch (_) {
      // Body is not JSON — return it as-is if non-empty
      if (body.isNotEmpty) return body;
    }

    return defaultFallback;
  }

  /// Strips the "Exception: " prefix Flutter adds when rethrowing
  /// and returns only the human-readable part.
  static String fromException(Object error) {
    return error.toString().replaceAll('Exception: ', '').trim();
  }

  static String fallbackForStatus(int? statusCode) {
    switch (statusCode) {
      case 400:
        return 'Invalid request.';
      case 401:
        return 'Session expired. Please log in again.';
      case 403:
        return 'You do not have permission to perform this action.';
      case 404:
        return 'The requested resource was not found.';
      case 500:
        return 'A server error occurred. Please try again later.';
      default:
        return 'An unexpected error occurred.';
    }
  }
}
