class Course {
  final int id;
  final String title;
  final String body; // used as description
  final int userId;

  Course({
    required this.id,
    required this.title,
    required this.body,
    required this.userId,
  });

  factory Course.fromJson(Map<String, dynamic> json) {
    return Course(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      body: json['body'] ?? '',
      userId: json['userId'] ?? 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'userId': userId,
    };
  }

  Course copyWith({
    int? id,
    String? title,
    String? body,
    int? userId,
  }) {
    return Course(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      userId: userId ?? this.userId,
    );
  }
}
