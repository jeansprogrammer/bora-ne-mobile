import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationModel {
  final String? id;
  final String userId;
  final String title;
  final String description;
  final String type; // favorito, roteiro, destino, promocao, avaliacao, dica, sistema
  final DateTime date;
  final bool read;

  NotificationModel({
    this.id,
    required this.userId,
    required this.title,
    required this.description,
    required this.type,
    required this.date,
    this.read = false,
  });

  factory NotificationModel.fromMap(Map<String, dynamic> map, {String? id}) {
    final rawDate = map['date'];
    final DateTime date =
        rawDate is Timestamp ? rawDate.toDate() : DateTime.now();

    return NotificationModel(
      id: id,
      userId: map['userId'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      type: map['type'] ?? 'sistema',
      date: date,
      read: map['read'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'title': title,
      'description': description,
      'type': type,
      'date': date,
      'read': read,
    };
  }
}
