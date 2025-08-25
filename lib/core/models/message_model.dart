class MessageModel {
  final String id;
  final String chatId;
  final String content;
  final String role; // 'user' or 'assistant'
  final DateTime createdAt;

  MessageModel({
    required this.id,
    required this.chatId,
    required this.content,
    required this.role,
    required this.createdAt,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['id'] ?? '',
      chatId: json['chatId'] ?? '',
      content: json['content'] ?? '',
      role: json['role'] ?? 'user',
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'chatId': chatId,
      'content': content,
      'role': role,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  bool get isUser => role == 'user';
  bool get isAssistant => role == 'assistant';
}
