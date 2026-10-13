import 'phone_contact.dart';
import 'phone_message.dart';
import 'phone_call.dart';

/// Notification entry on the phone lockscreen / alerts tray.
class PhoneNotification {
  final String id;
  final String title;
  final String body;
  final DateTime timestamp;
  final String category;

  const PhoneNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.timestamp,
    this.category = 'MISSION',
  });
}

/// Central manager for in-game smartphone state:
/// contacts, SMS threads, incoming/ongoing calls, and notifications.
class PhoneManager {
  final List<PhoneContact> contacts = List.from(PhoneContact.defaultContacts);
  final List<PhoneMessage> messages = [];
  final List<PhoneCall> callHistory = [];
  final List<PhoneNotification> notifications = [];

  PhoneCall? activeIncomingCall;
  PhoneCall? activeOngoingCall;

  // Event Callbacks
  void Function(PhoneCall call)? onIncomingCallTriggered;
  void Function(PhoneCall call)? onCallAnswered;
  void Function(PhoneCall call)? onCallEnded;
  void Function(PhoneMessage message)? onMessageReceived;
  void Function(String triggerId)? onStoryTriggerFired;

  PhoneManager() {
    _seedStarterPhoneData();
  }

  void _seedStarterPhoneData() {
    final now = DateTime.now();

    // Initial SMS threads
    messages.addAll([
      PhoneMessage(
        id: 'msg_meera_1',
        contactId: 'contact_meera',
        senderName: 'Meera',
        content: 'Vinod, please be careful near the highway checkpoint. Balan told me the police are stopping all vehicles today.',
        timestamp: now.subtract(const Duration(minutes: 45)),
        isFromPlayer: false,
        isRead: true,
      ),
      PhoneMessage(
        id: 'msg_rahu_1',
        contactId: 'contact_rahu',
        senderName: 'Rahu',
        content: 'Machan, I spotted Velu’s men scouting around the Old Town scrapyard. They are looking for something or someone. Stay alert.',
        timestamp: now.subtract(const Duration(minutes: 25)),
        isFromPlayer: false,
        isRead: false,
      ),
      PhoneMessage(
        id: 'msg_diya_intro',
        contactId: 'contact_diya',
        senderName: 'Diya',
        content: 'Vinod etta, some moneylender thugs came to the orchard asking for father’s old promissory note. Can you come by when you are free?',
        timestamp: now.subtract(const Duration(minutes: 10)),
        isFromPlayer: false,
        isRead: false,
        questTriggerId: 'sq_diya_dilemma',
      ),
    ]);

    // Initial system notification
    notifications.add(
      PhoneNotification(
        id: 'notif_welcome',
        title: 'NETWORK CONNECTED',
        body: 'BSNL 4G • Veyrapuram District Central Node connected.',
        timestamp: now.subtract(const Duration(hours: 1)),
        category: 'SYSTEM',
      ),
    );
  }

  int get unreadMessageCount =>
      messages.where((m) => !m.isFromPlayer && !m.isRead).length;

  bool get hasUnreadMessages => unreadMessageCount > 0;

  List<PhoneMessage> getMessagesForContact(String contactId) {
    return messages.where((m) => m.contactId == contactId).toList()
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));
  }

  void markThreadRead(String contactId) {
    for (final m in messages) {
      if (m.contactId == contactId && !m.isRead) {
        m.isRead = true;
      }
    }
  }

  /// Triggers an incoming call with ringing banner/dialog.
  void triggerIncomingCall(PhoneCall call) {
    activeIncomingCall = call;
    call.status = CallStatus.incoming;
    onIncomingCallTriggered?.call(call);
  }

  /// Answers the current incoming call.
  void answerIncomingCall() {
    if (activeIncomingCall == null) return;
    final call = activeIncomingCall!;
    activeIncomingCall = null;
    call.answer();
    activeOngoingCall = call;
    callHistory.add(call);
    onCallAnswered?.call(call);

    if (call.questTriggerId != null) {
      onStoryTriggerFired?.call(call.questTriggerId!);
    }
  }

  /// Declines the current incoming call.
  void declineIncomingCall() {
    if (activeIncomingCall == null) return;
    final call = activeIncomingCall!;
    activeIncomingCall = null;
    call.decline();
    callHistory.add(call);
    onCallEnded?.call(call);
  }

  /// Advances dialogue in an active ongoing call.
  /// Returns false if the call has concluded.
  bool advanceOngoingCall() {
    if (activeOngoingCall == null) return false;
    final call = activeOngoingCall!;
    final hasMore = call.advanceDialogue();
    if (!hasMore) {
      activeOngoingCall = null;
      onCallEnded?.call(call);
    }
    return hasMore;
  }

  /// Hangs up the active ongoing call.
  void hangUpOngoingCall() {
    if (activeOngoingCall == null) return;
    final call = activeOngoingCall!;
    call.status = CallStatus.completed;
    activeOngoingCall = null;
    onCallEnded?.call(call);
  }

  /// Receives an SMS message and posts a phone notification.
  void receiveMessage(PhoneMessage message) {
    messages.add(message);
    notifications.insert(
      0,
      PhoneNotification(
        id: 'notif_${message.id}',
        title: 'SMS: ${message.senderName}',
        body: message.content,
        timestamp: message.timestamp,
        category: 'SMS',
      ),
    );
    onMessageReceived?.call(message);

    if (message.questTriggerId != null) {
      onStoryTriggerFired?.call(message.questTriggerId!);
    }
  }

  /// Sends an SMS from the player to a contact.
  void sendPlayerMessage(String contactId, String text) {
    messages.add(
      PhoneMessage(
        id: 'msg_player_${DateTime.now().millisecondsSinceEpoch}',
        contactId: contactId,
        senderName: 'Vinod',
        content: text,
        timestamp: DateTime.now(),
        isFromPlayer: true,
        isRead: true,
      ),
    );
  }

  /// Pushes a mission / system notification to the phone.
  void pushNotification(String title, String body, {String category = 'MISSION'}) {
    notifications.insert(
      0,
      PhoneNotification(
        id: 'notif_${DateTime.now().millisecondsSinceEpoch}',
        title: title,
        body: body,
        timestamp: DateTime.now(),
        category: category,
      ),
    );
  }
}
