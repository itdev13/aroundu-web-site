

// Add enum for direction
enum RedirectionDirection {
  LEFT,
  RIGHT,
  CENTER,
}

// Extension to convert string to enum
extension RedirectionDirectionExtension on String {
  RedirectionDirection toRedirectionDirection() {
    switch (this) {
      case 'LEFT':
        return RedirectionDirection.LEFT;
      case 'RIGHT':
        return RedirectionDirection.RIGHT;
      case 'CENTER':
      default:
        return RedirectionDirection.CENTER;
    }
  }
}

class NotificationsMainModel {
  final List<NotificationBaseModel> genericNotifications;
  final List<NotificationBaseModel> accessNotifications;
  final List<NotificationBaseModel> invitationNotifications;

  NotificationsMainModel({
    required this.genericNotifications,
    required this.accessNotifications,
    required this.invitationNotifications,
  });

  factory NotificationsMainModel.fromJson(Map<String, dynamic> json) {
    return NotificationsMainModel(
      genericNotifications: (json['genericNotifications'] != null)
          ? (json['genericNotifications'] as List)
              .map((n) => NotificationBaseModel.fromJson(n))
              .toList()
          : <NotificationBaseModel>[],
      accessNotifications: (json['accessNotifications'] != null)
          ? (json['accessNotifications'] as List)
              .map((n) => NotificationBaseModel.fromJson(n))
              .toList()
          : <NotificationBaseModel>[],
      invitationNotifications: (json['invitationNotifications'] != null)
          ? (json['invitationNotifications'] as List)
              .map((n) => NotificationBaseModel.fromJson(n))
              .toList()
          : <NotificationBaseModel>[],
    );
  }
}

// Base Notification Model
class NotificationBaseModel {
  final String id;
  final int createdDate;
  final int lastModifiedDate;
  final String title;
  final String body;
  final String notificationType;
  final String layoutType;
  final String userId;
  final List<NotificationUser> users;
  final int othersCount;
  final String? icon;
  final Entity entity;
  final List<NotificationActionButton>? buttons;
  final String baseRedirectionPath;
  final List<RedirectionPath> redirectionPaths;
  final bool read;

  NotificationBaseModel({
    required this.id,
    required this.createdDate,
    required this.lastModifiedDate,
    required this.title,
    required this.body,
    required this.notificationType,
    required this.layoutType,
    required this.userId,
    required this.users,
    required this.othersCount,
    this.icon,
    required this.entity,
    this.buttons,
    required this.baseRedirectionPath,
    required this.redirectionPaths,
    required this.read,
  });

  factory NotificationBaseModel.fromJson(Map<String, dynamic> json) {
    return NotificationBaseModel(
      id: json['id'],
      createdDate: json['createdDate'],
      lastModifiedDate: json['lastModifiedDate'],
      title: json['title'],
      body: json['body'],
      notificationType: json['notificationType'],
      layoutType: json['layoutType'],
      userId: json['userId'] ?? '',
      users: (json['users'] as List<dynamic>?)
              ?.map((user) => NotificationUser.fromJson(user))
              .toList() ??
          <NotificationUser>[],
      othersCount: json['othersCount'] ?? 0,
      icon: json['icon'] ?? '',
      entity: (json['entity'] != null)
          ? Entity.fromJson(json['entity'])
          : Entity.empty(),
      buttons: (json['buttons'] != null)
          ? (json['buttons'] as List<dynamic>)
              .map((button) => NotificationActionButton.fromJson(button))
              .toList()
          : <NotificationActionButton>[],
      baseRedirectionPath: json['baseRedirectionPath'] ?? '',
      redirectionPaths: (json['redirectionPaths'] != null)
          ? (json['redirectionPaths'] as List<dynamic>)
              .map((path) => RedirectionPath.fromJson(path))
              .toList()
          : <RedirectionPath>[],
      read: json['read'] ?? false,
    );
  }
}

// New class for redirection paths
class RedirectionPath {
  final RedirectionDirection direction;
  final String path;

  RedirectionPath({
    required this.direction,
    required this.path,
  });

  factory RedirectionPath.fromJson(Map<String, dynamic> json) => RedirectionPath(
        direction: (json['direction'] as String).toRedirectionDirection(),
        path: json['path'] ?? '',
      );
}

class NotificationUser {
  final String userId;
  final String userName;
  final String name;
  final String profilePicture;
  final String mobile;
  final String conversationId;

  NotificationUser({
    required this.userId,
    required this.userName,
    required this.name,
    required this.profilePicture,
    required this.mobile,
    required this.conversationId,
  });

  factory NotificationUser.fromJson(Map<String, dynamic> json) =>
      NotificationUser(
        userId: json['userId'] ?? '',
        userName: json['userName'] ?? '',
        name: json['name'] ?? '',
        profilePicture: json['profilePicture'] ?? '',
        mobile: json['mobile'] ?? '',
        conversationId: json['conversationId'] ?? '',
      );
}

class Entity {
  final String entityId;
  final String entityType;
  final String entityImage;
  final String entityDescription;

  Entity({
    required this.entityId,
    required this.entityType,
    required this.entityImage,
    required this.entityDescription,
  });

  factory Entity.fromJson(Map<String, dynamic> json) => Entity(
        entityId: json['entityId'] ?? '',
        entityType: json['entityType'] ?? '',
        entityImage: json['entityImage'] ?? '',
        entityDescription: json['entityDescription'] ?? '',
      );

  factory Entity.empty() => Entity(
        entityId: '',
        entityType: '',
        entityImage: '',
        entityDescription: '',
      );
}

class NotificationActionButton {
  final String action;
  final String title;
  final String icon;
  final String key;

  NotificationActionButton({
    required this.action,
    required this.title,
    required this.icon,
    required this.key,
  });

  factory NotificationActionButton.fromJson(Map<String, dynamic> json) =>
      NotificationActionButton(
        action: json['action'] ?? '',
        title: json['title'] ?? '',
        icon: json['icon'] ?? '',
        key: json['key'] ?? '',
      );
}
