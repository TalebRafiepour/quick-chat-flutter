class Chat {
  final String? userId;
  final String? userName;
  final String? message;
  final int time;
  final String color;

  Chat({
    this.userId,
    this.userName,
    this.message,
    required this.time,
    required this.color,
  });

  factory Chat.fromRawJson(Map<String, dynamic> jsonData) {
    return Chat(
        userName: jsonData['username'],
        message: jsonData['message'],
        time: jsonData['time'],
        color: jsonData['color'],
        userId: jsonData['userId']);
  }

  Map<String, dynamic> toJson() {
    return {
      "username": userName,
      "message": message,
      "userId": userId,
      "color": color,
    };
  }
}
