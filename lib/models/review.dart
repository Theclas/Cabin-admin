import 'package:cloud_firestore/cloud_firestore.dart';

class Review {
  final String id;
  final String placeId;
  final String placeName;
  final String userId;
  final String userName;
  final String? userPhoto;
  final double rating;
  final String comment;
  final List<String> photos;
  final bool isVisible;
  final bool isFlagged;
  final DateTime createdAt;

  const Review({
    required this.id,
    required this.placeId,
    required this.placeName,
    required this.userId,
    required this.userName,
    this.userPhoto,
    required this.rating,
    required this.comment,
    required this.photos,
    required this.isVisible,
    required this.isFlagged,
    required this.createdAt,
  });

  factory Review.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Review(
      id: doc.id,
      placeId: data['placeId'] ?? '',
      placeName: data['placeName'] ?? '',
      userId: data['userId'] ?? '',
      userName: data['userName'] ?? '',
      userPhoto: data['userPhoto'],
      rating: (data['rating'] as num?)?.toDouble() ?? 0,
      comment: data['comment'] ?? '',
      photos: List<String>.from(data['photos'] ?? []),
      isVisible: data['isVisible'] ?? true,
      isFlagged: data['isFlagged'] ?? false,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
        'placeId': placeId,
        'placeName': placeName,
        'userId': userId,
        'userName': userName,
        'userPhoto': userPhoto,
        'rating': rating,
        'comment': comment,
        'photos': photos,
        'isVisible': isVisible,
        'isFlagged': isFlagged,
        'createdAt': Timestamp.fromDate(createdAt),
      };
}
