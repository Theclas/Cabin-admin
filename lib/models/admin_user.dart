import 'package:cloud_firestore/cloud_firestore.dart';

class AdminUser {
  final String uid;
  final String email;
  final String displayName;
  final String? photoUrl;
  final String role;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? lastLogin;

  const AdminUser({
    required this.uid,
    required this.email,
    required this.displayName,
    this.photoUrl,
    required this.role,
    required this.isActive,
    required this.createdAt,
    this.lastLogin,
  });

  factory AdminUser.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AdminUser(
      uid: doc.id,
      email: data['email'] ?? '',
      displayName: data['displayName'] ?? data['name'] ?? '',
      photoUrl: data['photoUrl'],
      role: data['role'] ?? 'user',
      isActive: data['isActive'] ?? true,
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
        'createdAt': Timestamp.fromDate(createdAt),
        'lastLogin': lastLogin != null ? Timestamp.fromDate(lastLogin!) : null,
      };

  bool get isAdmin => role == 'admin' || role == 'superadmin';
  bool get isSuperAdmin => role == 'superadmin';
}
