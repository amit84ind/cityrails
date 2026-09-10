class ChatMessage {
  final int? id;
  final String senderName;
  final String stationName;
  final String line;
  final String message;
  final String timestamp;
  final int likes;

  ChatMessage({
    this.id,
    required this.senderName,
    required this.stationName,
    required this.line,
    required this.message,
    required this.timestamp,
    this.likes = 0,
  });

  factory ChatMessage.fromMap(Map<String, dynamic> map) {
    return ChatMessage(
      id: map['id'],
      senderName: map['sender_name'] ?? 'Commuter',
      stationName: map['station_name'] ?? '',
      line: map['line'] ?? '',
      message: map['message'] ?? '',
      timestamp: map['timestamp'] ?? '',
      likes: map['likes'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'sender_name': senderName,
      'station_name': stationName,
      'line': line,
      'message': message,
      'timestamp': timestamp,
      'likes': likes,
    };
  }
}
