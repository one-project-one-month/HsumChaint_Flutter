enum UiMessageType { success, error, warning, info }

class UiMessage {
  final UiMessageType type;
  final String title;
  final String message;

  const UiMessage({
    required this.type,
    required this.title,
    required this.message,
  });
}
