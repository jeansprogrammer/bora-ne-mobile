class DestinationComment {
  final String uid;
  final String userName;
  final String text;
  final DateTime createdAt;

  DestinationComment({
    required this.uid,
    required this.userName,
    required this.text,
    required this.createdAt,
  });

  factory DestinationComment.fromMap(Map<String, dynamic> map) {
    return DestinationComment(
      uid: map['uid'],
      userName: map['userName'],
      text: map['text'],
      createdAt: DateTime.parse(map['createdAt']),
    );
  }

  Map<String, dynamic> toMap() => {
    'uid': uid,
    'userName': userName,
    'text': text,
    'createdAt': createdAt.toIso8601String(),
  };
}
