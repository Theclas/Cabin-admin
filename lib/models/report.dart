import 'package:cloud_firestore/cloud_firestore.dart';

enum ReportStatus { pending, reviewing, resolved, dismissed }
enum ReportType { place, review, user, other }

class Report {
  final String id;
  final String reporterId;
  final String reporterName;
  final ReportType type;
  final String targetId;
  final String targetName;
  final String reason;
  final String? description;
  final ReportStatus status;
  final String? resolvedBy;
  final String? resolution;
  final DateTime createdAt;
  final DateTime? resolvedAt;

  const Report({
    required this.id,
    required this.reporterId,
    required this.reporterName,
    required this.type,
    required this.targetId,
    required this.targetName,
    required this.reason,
    this.description,
    required this.status,
    this.resolvedBy,
    this.resolution,
    required this.createdAt,
    this.resolvedAt,
  });

  factory Report.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Report(
      id: doc.id,
      reporterId: data['reporterId'] ?? '',
      reporterName: data['reporterName'] ?? '',
      type: ReportType.values.firstWhere(
        (e) => e.name == data['type'],
        orElse: () => ReportType.other,
      ),
      targetId: data['targetId'] ?? '',
      targetName: data['targetName'] ?? '',
      reason: data['reason'] ?? '',
      description: data['description'],
      status: ReportStatus.values.firstWhere(
        (e) => e.name == data['status'],
        orElse: () => ReportStatus.pending,
      ),
      resolvedBy: data['resolvedBy'],
      resolution: data['resolution'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      resolvedAt: (data['resolvedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() => {
        'reporterId': reporterId,
        'reporterName': reporterName,
        'type': type.name,
        'targetId': targetId,
        'targetName': targetName,
        'reason': reason,
        'description': description,
        'status': status.name,
        'resolvedBy': resolvedBy,
        'resolution': resolution,
        'createdAt': Timestamp.fromDate(createdAt),
        'resolvedAt': resolvedAt != null ? Timestamp.fromDate(resolvedAt!) : null,
      };
}
