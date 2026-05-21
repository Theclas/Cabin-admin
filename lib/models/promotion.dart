import 'package:cloud_firestore/cloud_firestore.dart';

enum PromotionType { discount, featured, banner, special }
enum PromotionStatus { active, scheduled, expired, paused }

class Promotion {
  final String id;
  final String title;
  final String description;
  final PromotionType type;
  final PromotionStatus status;
  final String? placeId;
  final String? placeName;
  final double? discountPercent;
  final String? bannerUrl;
  final String? couponCode;
  final DateTime startDate;
  final DateTime endDate;
  final int usageCount;
  final int? usageLimit;
  final DateTime createdAt;

  const Promotion({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.status,
    this.placeId,
    this.placeName,
    this.discountPercent,
    this.bannerUrl,
    this.couponCode,
    required this.startDate,
    required this.endDate,
    required this.usageCount,
    this.usageLimit,
    required this.createdAt,
  });

  factory Promotion.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Promotion(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      type: PromotionType.values.firstWhere(
        (e) => e.name == data['type'],
        orElse: () => PromotionType.featured,
      ),
      status: PromotionStatus.values.firstWhere(
        (e) => e.name == data['status'],
        orElse: () => PromotionStatus.paused,
      ),
      placeId: data['placeId'],
      placeName: data['placeName'],
      discountPercent: (data['discountPercent'] as num?)?.toDouble(),
      bannerUrl: data['bannerUrl'],
      couponCode: data['couponCode'],
      startDate: (data['startDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      endDate: (data['endDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      usageCount: (data['usageCount'] as num?)?.toInt() ?? 0,
      usageLimit: (data['usageLimit'] as num?)?.toInt(),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
        'title': title,
        'description': description,
        'type': type.name,
        'status': status.name,
        'placeId': placeId,
        'placeName': placeName,
        'discountPercent': discountPercent,
        'bannerUrl': bannerUrl,
        'couponCode': couponCode,
        'startDate': Timestamp.fromDate(startDate),
        'endDate': Timestamp.fromDate(endDate),
        'usageCount': usageCount,
        'usageLimit': usageLimit,
        'createdAt': Timestamp.fromDate(createdAt),
      };

  bool get isCurrentlyActive =>
      status == PromotionStatus.active &&
      DateTime.now().isAfter(startDate) &&
      DateTime.now().isBefore(endDate);
}
