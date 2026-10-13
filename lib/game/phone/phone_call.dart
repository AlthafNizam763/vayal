/// State of a phone call.
enum CallStatus {
  incoming,
  active,
  completed,
  declined,
  missed,
}

/// Model representing a phone call in VAYAL.
class PhoneCall {
  final String id;
  final String contactId;
  final String callerName;
  final String callerRole;
  final List<String> dialogueLines;
  final String? questTriggerId;
  CallStatus status;
  int currentLineIndex;

  PhoneCall({
    required this.id,
    required this.contactId,
    required this.callerName,
    required this.callerRole,
    required this.dialogueLines,
    this.questTriggerId,
    this.status = CallStatus.incoming,
    this.currentLineIndex = 0,
  });

  String? get currentLine =>
      (currentLineIndex >= 0 && currentLineIndex < dialogueLines.length)
          ? dialogueLines[currentLineIndex]
          : null;

  bool advanceDialogue() {
    if (currentLineIndex < dialogueLines.length - 1) {
      currentLineIndex++;
      return true; // Still has lines
    } else {
      status = CallStatus.completed;
      return false; // Ended
    }
  }

  void answer() {
    status = CallStatus.active;
    currentLineIndex = 0;
  }

  void decline() {
    status = CallStatus.declined;
  }

  void miss() {
    status = CallStatus.missed;
  }
}
