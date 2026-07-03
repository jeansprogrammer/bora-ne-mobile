import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationModel {
  String icon;
  String title;
  String description;
  DateTime date;

  NotificationModel({
    required this.icon,
    required this.title,
    required this.description,
    required this.date,
  });

  factory NotificationModel.fromMap(Map<String, dynamic> map) {
    final rawDate = map['date'];
    final DateTime date = rawDate is Timestamp ? rawDate.toDate() : DateTime.now();

    return NotificationModel(
      icon: map['icon'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',

      date: date,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'icon': icon,
      'title': title,
      'description': description,

      'date': date.toUtc(),
    };
  }
}
