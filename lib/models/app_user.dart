import 'package:cloud_firestore/cloud_firestore.dart';

class AppUser {
  final String uid;
  final String email;
  final String displayName;
  final String? photoUrl;
  final String role;
  final bool isActive;
  final bool isBanned;
  final String? banReason;
  final int reviewCount;
  final DateTime createdAt;
  final DateTime? lastLogin;

  const AppUser({
    required this.uid,
    required this.email,
    required this.displayName,
    this.photoUrl,
    required this.role,
    required this.isActive,
    required this.isBanned,
    this.banReason,
    required this.reviewCount,
    required this.createdAt,
    this.lastLogin,
  });

  factory AppUser.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AppUser(
      uid: doc.id,
      email: data['email'] ?? '',
      displayName: data['displayName'] ?? data['name'] ?? '',
      photoUrl: data['photoUrl'],
      role: data['role'] ?? 'user',
      isActive: data['isActive'] ?? true,
      isBanned: data['isBanned'] ?? false,
      banReason: data['banReason'],
      reviewCount: (data['reviewCount'] as num?)?.toInt() ?? 0,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      lastLogin: (data['lastLogin'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() => {
        'email': email,
        'displayName': displayName,
        'photoUrl': photoUrl,
        'role': role,
        'isActive': isActive,
        'isBanned': isBanned,
        'banReason': banReason,
        'reviewCount': reviewCount,
        'createdAt': Timestamp.fromDate(createdAt),
        'lastLogin': lastLogin != null ? Timestamp.fromDate(lastLogin!) : null,
      };
}
