import 'package:cloud_firestore/cloud_firestore.dart';

class RouteComment {
  final String? id;
  final String routeId;
  final String userId;
  final String userName;
  final String message;
  final DateTime? createdAt;

  RouteComment({
    this.id,
    required this.routeId,
    required this.userId,
    required this.userName,
    required this.message,
    this.createdAt,
  });

  factory RouteComment.fromMap(Map<String, dynamic> map, {String? id}) {
    final createdAtRaw = map['createdAt'];
    return RouteComment(
      id: id,
      routeId: map['routeId'] ?? '',
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? '',
      message: map['message'] ?? '',
      createdAt: createdAtRaw is Timestamp ? createdAtRaw.toDate() : null,
    );
  }

  Map<String, dynamic> toMap() => {
    'routeId': routeId,
    'userId': userId,
    'userName': userName,
    'message': message,
    'createdAt': FieldValue.serverTimestamp(),
  };
}
