import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../game/phone/phone_contact.dart';
import '../../game/phone/phone_call.dart';
import '../../game/phone/phone_manager.dart';

/// Top-of-screen animated Incoming Call banner with [Answer] and [Decline].
class IncomingCallBanner extends StatelessWidget {
  final PhoneCall call;
  final VoidCallback onAnswer;
  final VoidCallback onDecline;

  const IncomingCallBanner({
    super.key,
    required this.call,
    required this.onAnswer,
    required this.onDecline,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Align(
        alignment: Alignment.topRight,
        child: Container(
          width: 320.0,
          margin: const EdgeInsets.only(top: 14.0, right: 16.0),
          padding: const EdgeInsets.all(12.0),
          decoration: BoxDecoration(
            color: const Color(0xFF111622).withValues(alpha: 0.95),
            borderRadius: BorderRadius.circular(12.0),
            border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.8), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF10B981).withValues(alpha: 0.25),
                blurRadius: 18.0,
                spreadRadius: 2.0,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Container(
                    width: 38.0,
                    height: 38.0,
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981).withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFF10B981)),
                    ),
                    child: const Icon(Icons.phone_in_talk_rounded, color: Color(0xFF10B981), size: 20.0),
                  ),
                  const SizedBox(width: 10.0),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'INCOMING CALL',
                          style: TextStyle(
                            color: Color(0xFF10B981),
                            fontSize: 9.5,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.5,
                          ),
                        ),
                        Text(
                          call.callerName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          call.callerRole,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: Colors.white60, fontSize: 10.5),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12.0),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFEF4444),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6.0)),
                      ),
                      icon: const Icon(Icons.call_end_rounded, size: 14.0),
                      label: const Text('DECLINE', style: TextStyle(fontSize: 11.0, fontWeight: FontWeight.bold)),
                      onPressed: onDecline,
                    ),
                  ),
                  const SizedBox(width: 8.0),
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF10B981),
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6.0)),
                      ),
                      icon: const Icon(Icons.call_rounded, size: 14.0),
                      label: const Text('ANSWER', style: TextStyle(fontSize: 11.0, fontWeight: FontWeight.bold)),
                      onPressed: onAnswer,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Active Ongoing Call speech bubble / dialog.
class OngoingCallBanner extends StatelessWidget {
  final PhoneCall call;
  final VoidCallback onAdvance;
  final VoidCallback onHangUp;

  const OngoingCallBanner({
    super.key,
    required this.call,
    required this.onAdvance,
    required this.onHangUp,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Align(
        alignment: Alignment.topCenter,
        child: Container(
          width: 520.0,
          margin: const EdgeInsets.only(top: 20.0),
          padding: const EdgeInsets.all(14.0),
          decoration: BoxDecoration(
            color: const Color(0xFF0F141F).withValues(alpha: 0.96),
            borderRadius: BorderRadius.circular(10.0),
            border: Border.all(color: const Color(0xFF38BDF8), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.6),
                blurRadius: 20.0,
                spreadRadius: 4.0,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.phone_android_rounded, color: Color(0xFF38BDF8), size: 16.0),
                  const SizedBox(width: 6.0),
                  Text(
                    'CALL IN PROGRESS // ${call.callerName.toUpperCase()}',
                    style: const TextStyle(
                      color: Color(0xFF38BDF8),
                      fontSize: 10.5,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.call_end_rounded, color: Color(0xFFEF4444), size: 18.0),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: onHangUp,
                  ),
                ],
              ),
              const SizedBox(height: 8.0),
              Text(
                call.currentLine ?? '',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13.5,
                  fontWeight: FontWeight.w500,
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 10.0),
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF38BDF8),
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 6.0),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.0)),
                  ),
                  icon: const Icon(Icons.arrow_forward_rounded, size: 14.0),
                  label: const Text('CONTINUE', style: TextStyle(fontSize: 11.0, fontWeight: FontWeight.bold)),
                  onPressed: onAdvance,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Full interactive smartphone screen view (Contacts, SMS Threads, Notifications).
class PhoneOverlay extends StatefulWidget {
  final PhoneManager phoneManager;
  final String currentTimeString;
  final VoidCallback onClose;
  final ValueChanged<String>? onInitiateQuest;

  const PhoneOverlay({
    super.key,
    required this.phoneManager,
    required this.currentTimeString,
    required this.onClose,
    this.onInitiateQuest,
  });

  @override
  State<PhoneOverlay> createState() => _PhoneOverlayState();
}

class _PhoneOverlayState extends State<PhoneOverlay> {
  int _activeTabIndex = 0; // 0: Messages, 1: Contacts, 2: Notifications
  PhoneContact? _selectedContactForChat;
  final TextEditingController _replyController = TextEditingController();

  @override
  void dispose() {
    _replyController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final text = _replyController.text.trim();
    if (text.isEmpty || _selectedContactForChat == null) return;
    widget.phoneManager.sendPlayerMessage(_selectedContactForChat!.id, text);
    _replyController.clear();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black.withValues(alpha: 0.7),
      body: Center(
        child: Builder(builder: (context) {
          // Shrink the phone (portrait aspect kept) to fit landscape screens.
          final screen = MediaQuery.of(context).size;
          final phoneH = math.min(640.0, screen.height * 0.94);
          final phoneW = phoneH * (360.0 / 640.0);
          return Container(
            width: phoneW,
            height: phoneH,
          decoration: BoxDecoration(
            color: const Color(0xFF0C1017),
            borderRadius: BorderRadius.circular(32.0),
            border: Border.all(color: const Color(0xFF3A4454), width: 3.0),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.8),
                blurRadius: 30.0,
                spreadRadius: 8.0,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(29.0),
            child: Column(
              children: [
                // Phone Status Bar
                Container(
                  height: 36.0,
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  color: const Color(0xFF141923),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        widget.currentTimeString,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12.0,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'monospace',
                        ),
                      ),
                      // Camera punch-hole
                      Container(
                        width: 10.0,
                        height: 10.0,
                        decoration: const BoxDecoration(
                          color: Colors.black,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const Row(
                        children: [
                          Icon(Icons.network_cell_rounded, color: Colors.white70, size: 14.0),
                          SizedBox(width: 4.0),
                          Text('BSNL 4G', style: TextStyle(color: Colors.white70, fontSize: 9.0)),
                          SizedBox(width: 6.0),
                          Icon(Icons.battery_5_bar_rounded, color: Colors.white70, size: 14.0),
                        ],
                      ),
                    ],
                  ),
                ),

                // App Body
                Expanded(
                  child: _selectedContactForChat != null
                      ? _buildChatConversationView(_selectedContactForChat!)
                      : _buildActiveAppBody(),
                ),

                // Phone Bottom App Switcher Bar
                Container(
                  height: 52.0,
                  decoration: const BoxDecoration(
                    color: Color(0xFF121620),
                    border: Border(top: BorderSide(color: Colors.white12)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildNavTab(
                        index: 0,
                        icon: Icons.chat_bubble_outline_rounded,
                        label: 'SMS',
                        badgeCount: widget.phoneManager.unreadMessageCount,
                      ),
                      _buildNavTab(
                        index: 1,
                        icon: Icons.contacts_outlined,
                        label: 'Contacts',
                      ),
                      _buildNavTab(
                        index: 2,
                        icon: Icons.notifications_none_rounded,
                        label: 'Alerts',
                        badgeCount: widget.phoneManager.notifications.length,
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded, color: Colors.white70, size: 20.0),
                        onPressed: widget.onClose,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      }),
      ),
    );
  }

  Widget _buildNavTab({
    required int index,
    required IconData icon,
    required String label,
    int badgeCount = 0,
  }) {
    final isSelected = _selectedContactForChat == null && _activeTabIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedContactForChat = null;
          _activeTabIndex = index;
        });
      },
      child: Container(
        color: Colors.transparent,
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Badge(
              isLabelVisible: badgeCount > 0,
              label: Text('$badgeCount', style: const TextStyle(fontSize: 8.0)),
              child: Icon(
                icon,
                color: isSelected ? const Color(0xFFD97736) : Colors.white60,
                size: 20.0,
              ),
            ),
            const SizedBox(height: 2.0),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? const Color(0xFFD97736) : Colors.white60,
                fontSize: 9.5,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveAppBody() {
    switch (_activeTabIndex) {
      case 0:
        return _buildMessagesList();
      case 1:
        return _buildContactsList();
      case 2:
        return _buildNotificationsList();
      default:
        return _buildMessagesList();
    }
  }

  Widget _buildMessagesList() {
    final contactsWithMessages = widget.phoneManager.contacts.where((c) {
      return widget.phoneManager.getMessagesForContact(c.id).isNotEmpty;
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
          color: const Color(0xFF141A25),
          child: const Text(
            'MESSAGES',
            style: TextStyle(color: Colors.white, fontSize: 14.0, fontWeight: FontWeight.bold, letterSpacing: 1.5),
          ),
        ),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.all(12.0),
            itemCount: contactsWithMessages.length,
            separatorBuilder: (_, index) => const Divider(color: Colors.white10, height: 1.0),
            itemBuilder: (context, index) {
              final contact = contactsWithMessages[index];
              final thread = widget.phoneManager.getMessagesForContact(contact.id);
              final lastMsg = thread.last;
              final unread = thread.where((m) => !m.isFromPlayer && !m.isRead).length;

              return ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 4.0),
                leading: CircleAvatar(
                  backgroundColor: contact.themeColor,
                  child: Text(
                    contact.avatarInitials,
                    style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                  ),
                ),
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      contact.name,
                      style: const TextStyle(color: Colors.white, fontSize: 13.0, fontWeight: FontWeight.bold),
                    ),
                    if (unread > 0)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 2.0),
                        decoration: BoxDecoration(
                          color: const Color(0xFFD97736),
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        child: Text(
                          '$unread NEW',
                          style: const TextStyle(color: Colors.black, fontSize: 8.5, fontWeight: FontWeight.bold),
                        ),
                      ),
                  ],
                ),
                subtitle: Text(
                  lastMsg.content,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: unread > 0 ? Colors.white : Colors.white60,
                    fontWeight: unread > 0 ? FontWeight.bold : FontWeight.normal,
                    fontSize: 11.5,
                  ),
                ),
                onTap: () {
                  setState(() {
                    _selectedContactForChat = contact;
                    widget.phoneManager.markThreadRead(contact.id);
                  });
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildChatConversationView(PhoneContact contact) {
    final messages = widget.phoneManager.getMessagesForContact(contact.id);

    return Column(
      children: [
        // Chat Header
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
          color: const Color(0xFF141A25),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_rounded, color: Colors.white70, size: 20.0),
                onPressed: () {
                  setState(() {
                    _selectedContactForChat = null;
                  });
                },
              ),
              CircleAvatar(
                radius: 14.0,
                backgroundColor: contact.themeColor,
                child: Text(contact.avatarInitials, style: const TextStyle(fontSize: 11.0, color: Colors.black, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(width: 8.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(contact.name, style: const TextStyle(color: Colors.white, fontSize: 13.0, fontWeight: FontWeight.bold)),
                    Text(contact.role, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white54, fontSize: 9.5)),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Message Bubbles
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(12.0),
            itemCount: messages.length,
            itemBuilder: (context, index) {
              final msg = messages[index];
              final isMe = msg.isFromPlayer;

              return Align(
                alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 4.0),
                  padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                  constraints: const BoxConstraints(maxWidth: 240.0),
                  decoration: BoxDecoration(
                    color: isMe ? const Color(0xFFD97736) : const Color(0xFF1B2332),
                    borderRadius: BorderRadius.circular(10.0),
                    border: Border.all(color: isMe ? Colors.transparent : Colors.white12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        msg.content,
                        style: TextStyle(
                          color: isMe ? Colors.black : Colors.white,
                          fontSize: 12.0,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (msg.questTriggerId != null) ...[
                        const SizedBox(height: 6.0),
                        GestureDetector(
                          onTap: () {
                            widget.onInitiateQuest?.call(msg.questTriggerId!);
                            widget.onClose();
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 3.0),
                            decoration: BoxDecoration(
                              color: const Color(0xFF10B981).withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(4.0),
                              border: Border.all(color: const Color(0xFF10B981)),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.assignment_outlined, size: 12.0, color: Color(0xFF10B981)),
                                SizedBox(width: 4.0),
                                Text(
                                  'VIEW SIDE STORY',
                                  style: TextStyle(color: Color(0xFF10B981), fontSize: 9.0, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            },
          ),
        ),

        // Reply Input Bar
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
          color: const Color(0xFF141923),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _replyController,
                  style: const TextStyle(color: Colors.white, fontSize: 12.0),
                  decoration: InputDecoration(
                    hintText: 'Type a message...',
                    hintStyle: const TextStyle(color: Colors.white38, fontSize: 11.5),
                    filled: true,
                    fillColor: const Color(0xFF0F131C),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(20.0), borderSide: BorderSide.none),
                  ),
                  onSubmitted: (_) => _sendMessage(),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.send_rounded, color: Color(0xFFD97736), size: 18.0),
                onPressed: _sendMessage,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildContactsList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
          color: const Color(0xFF141A25),
          child: const Text(
            'CONTACTS',
            style: TextStyle(color: Colors.white, fontSize: 14.0, fontWeight: FontWeight.bold, letterSpacing: 1.5),
          ),
        ),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.all(12.0),
            itemCount: widget.phoneManager.contacts.length,
            separatorBuilder: (_, index) => const Divider(color: Colors.white10, height: 1.0),
            itemBuilder: (context, index) {
              final contact = widget.phoneManager.contacts[index];

              return ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 2.0),
                leading: CircleAvatar(
                  backgroundColor: contact.themeColor,
                  child: Text(contact.avatarInitials, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                ),
                title: Text(contact.name, style: const TextStyle(color: Colors.white, fontSize: 13.0, fontWeight: FontWeight.bold)),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(contact.role, style: const TextStyle(color: Colors.white70, fontSize: 10.5)),
                    Text(contact.phoneNumber, style: const TextStyle(color: Colors.white38, fontSize: 9.5, fontFamily: 'monospace')),
                  ],
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.chat_bubble_outline_rounded, color: Colors.white70, size: 18.0),
                      onPressed: () {
                        setState(() {
                          _selectedContactForChat = contact;
                          widget.phoneManager.markThreadRead(contact.id);
                        });
                      },
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildNotificationsList() {
    final notifs = widget.phoneManager.notifications;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
          color: const Color(0xFF141A25),
          child: const Text(
            'SYSTEM & DISPATCH ALERTS',
            style: TextStyle(color: Colors.white, fontSize: 14.0, fontWeight: FontWeight.bold, letterSpacing: 1.5),
          ),
        ),
        Expanded(
          child: notifs.isEmpty
              ? const Center(
                  child: Text('No new notifications', style: TextStyle(color: Colors.white38, fontSize: 12.0)),
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(12.0),
                  itemCount: notifs.length,
                  separatorBuilder: (_, index) => const SizedBox(height: 8.0),
                  itemBuilder: (context, index) {
                    final n = notifs[index];
                    return Container(
                      padding: const EdgeInsets.all(10.0),
                      decoration: BoxDecoration(
                        color: const Color(0xFF141924),
                        borderRadius: BorderRadius.circular(8.0),
                        border: Border.all(color: Colors.white12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                n.category,
                                style: const TextStyle(color: Color(0xFFD97736), fontSize: 9.0, fontWeight: FontWeight.bold, letterSpacing: 1.2),
                              ),
                              Text(
                                '${n.timestamp.hour.toString().padLeft(2, '0')}:${n.timestamp.minute.toString().padLeft(2, '0')}',
                                style: const TextStyle(color: Colors.white38, fontSize: 9.0, fontFamily: 'monospace'),
                              ),
                            ],
                          ),
                          const SizedBox(height: 3.0),
                          Text(n.title, style: const TextStyle(color: Colors.white, fontSize: 12.0, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 2.0),
                          Text(n.body, style: const TextStyle(color: Colors.white70, fontSize: 10.5)),
                        ],
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
