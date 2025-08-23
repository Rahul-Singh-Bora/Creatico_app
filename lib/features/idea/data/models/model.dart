class IdeaModel {
  final String id;
  final String content;
  final String platform;
  final String tone;
  final DateTime createdAt;

  IdeaModel({
    required this.id,
    required this.content,
    required this.platform,
    required this.tone,
    required this.createdAt,
  });

  factory IdeaModel.fromJson(Map<String, dynamic> json) {
    return IdeaModel(
      id: json['id'] ?? '',
      content: json['content'] ?? '',
      platform: json['platform'] ?? '',
      tone: json['tone'] ?? '',
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
    );
  }
}
