import 'package:cloud_firestore/cloud_firestore.dart';

enum PopupActionType { none, url, place, promotion }

enum PopupAdStatus { active, scheduled, expired, paused }

class PopupAd {
  final String id;
  final String title;
  final String imageUrl;
  final PopupActionType actionType;
  final String? actionValue;
  final String? actionLabel; // human-readable label for place/promotion name
  final bool active;
  final DateTime startDate;
  final DateTime endDate;
  final int maxDisplaysPerUser;
  final int displayDelaySeconds;
  final int minTimeBeforeClose;
  final List<String> showOnScreens;
  final int priority;
  final bool dismissible;
  final bool showCloseButton;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int totalImpressions;
  final int totalClicks;
  final int totalDismissed;

  const PopupAd({
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.actionType,
    this.actionValue,
    this.actionLabel,
    required this.active,
    required this.startDate,
    required this.endDate,
    required this.maxDisplaysPerUser,
    required this.displayDelaySeconds,
    required this.minTimeBeforeClose,
    required this.showOnScreens,
    required this.priority,
    required this.dismissible,
    required this.showCloseButton,
    required this.createdAt,
    required this.updatedAt,
    required this.totalImpressions,
    required this.totalClicks,
    required this.totalDismissed,
  });

  factory PopupAd.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return PopupAd(
      id: doc.id,
      title: d['title'] as String? ?? '',
      imageUrl: d['imageUrl'] as String? ?? '',
      actionType: PopupActionType.values.firstWhere(
        (e) => e.name == (d['actionType'] as String? ?? 'none'),
        orElse: () => PopupActionType.none,
      ),
      actionValue: d['actionValue'] as String?,
      actionLabel: d['actionLabel'] as String?,
      active: d['active'] as bool? ?? false,
      startDate:
          (d['startDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      endDate: (d['endDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      maxDisplaysPerUser:
          (d['maxDisplaysPerUser'] as num?)?.toInt() ?? 3,
      displayDelaySeconds:
          (d['displayDelaySeconds'] as num?)?.toInt() ?? 0,
      minTimeBeforeClose:
          (d['minTimeBeforeClose'] as num?)?.toInt() ?? 0,
      showOnScreens:
          List<String>.from(d['showOnScreens'] as List? ?? []),
      priority: (d['priority'] as num?)?.toInt() ?? 5,
      dismissible: d['dismissible'] as bool? ?? true,
      showCloseButton: d['showCloseButton'] as bool? ?? true,
      createdAt:
          (d['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt:
          (d['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      totalImpressions: (d['totalImpressions'] as num?)?.toInt() ?? 0,
      totalClicks: (d['totalClicks'] as num?)?.toInt() ?? 0,
      totalDismissed: (d['totalDismissed'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toMap() => {
        'title': title,
        'imageUrl': imageUrl,
        'actionType': actionType.name,
        'actionValue': actionValue,
        'actionLabel': actionLabel,
        'active': active,
        'startDate': Timestamp.fromDate(startDate),
        'endDate': Timestamp.fromDate(endDate),
        'maxDisplaysPerUser': maxDisplaysPerUser,
        'displayDelaySeconds': displayDelaySeconds,
        'minTimeBeforeClose': minTimeBeforeClose,
        'showOnScreens': showOnScreens,
        'priority': priority,
        'dismissible': dismissible,
        'showCloseButton': showCloseButton,
        'updatedAt': FieldValue.serverTimestamp(),
        'totalImpressions': totalImpressions,
        'totalClicks': totalClicks,
        'totalDismissed': totalDismissed,
      };

  PopupAdStatus get computedStatus {
    final now = DateTime.now();
    if (!active) return PopupAdStatus.paused;
    if (startDate.isAfter(now)) return PopupAdStatus.scheduled;
    if (endDate.isBefore(now)) return PopupAdStatus.expired;
    return PopupAdStatus.active;
  }

  double get ctr =>
      totalImpressions == 0 ? 0 : totalClicks / totalImpressions * 100;
}
