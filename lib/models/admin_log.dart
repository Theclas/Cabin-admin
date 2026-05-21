import 'package:cloud_firestore/cloud_firestore.dart';

class AdminLog {
  final String id;
  final String adminId;
  final String adminEmail;
  final String action;
  final String targetType;
  final String? targetId;
  final Map<String, dynamic> details;
  final DateTime createdAt;

  const AdminLog({
    required this.id,
    required this.adminId,
    required this.adminEmail,
    required this.action,
    required this.targetType,
    this.targetId,
    required this.details,
    required this.createdAt,
  });

  factory AdminLog.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AdminLog(
      id: doc.id,
      adminId: data['adminId'] ?? '',
      adminEmail: data['adminEmail'] ?? '',
      action: data['action'] ?? '',
      targetType: data['targetType'] ?? '',
      targetId: data['targetId'],
      details: Map<String, dynamic>.from(data['details'] ?? {}),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
        'adminId': adminId,
        'adminEmail': adminEmail,
        'action': action,
        'targetType': targetType,
        'targetId': targetId,
        'details': details,
        'createdAt': Timestamp.fromDate(createdAt),
      };
}
