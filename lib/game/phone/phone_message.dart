/// Model for SMS / text messages in the player's smartphone.
class PhoneMessage {
  final String id;
  final String contactId;
  final String senderName;
  final String content;
  final DateTime timestamp;
  final bool isFromPlayer;
  bool isRead;
  final String? questTriggerId;

  PhoneMessage({
    required this.id,
    required this.contactId,
    required this.senderName,
    required this.content,
    required this.timestamp,
    required this.isFromPlayer,
    this.isRead = false,
    this.questTriggerId,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'contactId': contactId,
    'senderName': senderName,
    'content': content,
    'timestamp': timestamp.toIso8601String(),
    'isFromPlayer': isFromPlayer,
    'isRead': isRead,
    'questTriggerId': questTriggerId,
  };

  factory PhoneMessage.fromJson(Map<String, dynamic> json) => PhoneMessage(
    id: json['id'] as String,
    contactId: json['contactId'] as String,
    senderName: json['senderName'] as String,
    content: json['content'] as String,
    timestamp: DateTime.parse(json['timestamp'] as String),
    isFromPlayer: json['isFromPlayer'] as bool,
    isRead: json['isRead'] as bool? ?? false,
    questTriggerId: json['questTriggerId'] as String?,
  );
}
