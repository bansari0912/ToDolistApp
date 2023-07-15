import 'package:cloud_firestore/cloud_firestore.dart';

class Task {
  final String id;
  final String title;
  final String otherInfo;
  final bool isCompleted;
  final DateTime? dueDate;

  Task({
    required this.id,
    required this.title,
    required this.otherInfo,

    required this.isCompleted,
    required this.dueDate,
  });

  factory Task.fromSnapshot(DocumentSnapshot snapshot) {
    Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
    return Task(
      id: snapshot.id,
      title: data['title'],
      otherInfo: data['otherInfo'],
      isCompleted: data['isCompleted'],
      dueDate: data['dueDate']?.toDate(),
    );
  }
}
