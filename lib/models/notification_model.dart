// models/notification_model.dart

class NotificationModel {
  final int id;
  final String title;
  final String content;
  final String? redirectUrl;
  final String? imageUrl;
  final String? typeName;
  final String? typeIcon;
  final String? typeColor;
  final bool isRead;
  final DateTime createdAt;

  NotificationModel({
    required this.id,
    required this.title,
    required this.content,
    this.redirectUrl,
    this.imageUrl,
    this.typeName,
    this.typeIcon,
    this.typeColor,
    required this.isRead,
    required this.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] as int,
      title: json['title'] as String,
      content: json['content'] as String,
      redirectUrl: json['redirect_url'] as String?,
      imageUrl: json['image_url'] as String?,
      typeName: json['type_name'] as String?,
      typeIcon: json['type_icon'] as String?,
      typeColor: json['type_color'] as String?,
      isRead: json['is_read'] as bool,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'redirect_url': redirectUrl,
      'image_url': imageUrl,
      'type_name': typeName,
      'type_icon': typeIcon,
      'type_color': typeColor,
      'is_read': isRead,
      'created_at': createdAt.toIso8601String(),
    };
  }

  /// Copy với một số trường được thay đổi
  NotificationModel copyWith({
    int? id,
    String? title,
    String? content,
    String? redirectUrl,
    String? imageUrl,
    String? typeName,
    String? typeIcon,
    String? typeColor,
    bool? isRead,
    DateTime? createdAt,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      redirectUrl: redirectUrl ?? this.redirectUrl,
      imageUrl: imageUrl ?? this.imageUrl,
      typeName: typeName ?? this.typeName,
      typeIcon: typeIcon ?? this.typeIcon,
      typeColor: typeColor ?? this.typeColor,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// Lấy thời gian hiển thị (ví dụ: "2 giờ trước")
  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inDays > 7) {
      return '${createdAt.day}/${createdAt.month}/${createdAt.year}';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} ngày trước';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} giờ trước';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} phút trước';
    } else {
      return 'Vừa xong';
    }
  }
}
