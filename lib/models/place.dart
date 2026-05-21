import 'package:cloud_firestore/cloud_firestore.dart';

class Place {
  final String id;
  final String name;
  final String description;
  final String type;
  final String address;
  final String city;
  final String state;
  final double lat;
  final double lng;
  final List<String> photos;
  final List<String> amenities;
  final double pricePerNight;
  final double rating;
  final int reviewCount;
  final bool isActive;
  final bool isFeatured;
  final String? ownerId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Map<String, dynamic> extras;

  const Place({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.address,
    required this.city,
    required this.state,
    required this.lat,
    required this.lng,
    required this.photos,
    required this.amenities,
    required this.pricePerNight,
    required this.rating,
    required this.reviewCount,
    required this.isActive,
    required this.isFeatured,
    this.ownerId,
    required this.createdAt,
    required this.updatedAt,
    required this.extras,
  });

  factory Place.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final loc = data['location'] as Map<String, dynamic>?;
    final geo = data['geopoint'] as GeoPoint?;
    return Place(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      type: data['type'] ?? 'cabin',
      address: data['address'] ?? '',
      city: data['city'] ?? loc?['city'] ?? '',
      state: data['state'] ?? loc?['state'] ?? '',
      lat: geo?.latitude ?? (data['lat'] as num?)?.toDouble() ?? 0,
      lng: geo?.longitude ?? (data['lng'] as num?)?.toDouble() ?? 0,
      photos: List<String>.from(data['photos'] ?? []),
      amenities: List<String>.from(data['amenities'] ?? []),
      pricePerNight: (data['pricePerNight'] as num?)?.toDouble() ?? 0,
      rating: (data['rating'] as num?)?.toDouble() ?? 0,
      reviewCount: (data['reviewCount'] as num?)?.toInt() ?? 0,
      isActive: data['isActive'] ?? true,
      isFeatured: data['isFeatured'] ?? false,
      ownerId: data['ownerId'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      extras: Map<String, dynamic>.from(data['extras'] ?? {}),
    );
  }

  Map<String, dynamic> toMap() => {
        'name': name,
        'description': description,
        'type': type,
        'address': address,
        'city': city,
        'state': state,
        'geopoint': GeoPoint(lat, lng),
        'location': {'city': city, 'state': state},
        'photos': photos,
        'amenities': amenities,
        'pricePerNight': pricePerNight,
        'rating': rating,
        'reviewCount': reviewCount,
        'isActive': isActive,
        'isFeatured': isFeatured,
        'ownerId': ownerId,
        'createdAt': Timestamp.fromDate(createdAt),
        'updatedAt': Timestamp.fromDate(updatedAt),
        'extras': extras,
      };

  Place copyWith({
    String? name,
    String? description,
    String? type,
    String? address,
    String? city,
    String? state,
    double? lat,
    double? lng,
    List<String>? photos,
    List<String>? amenities,
    double? pricePerNight,
    bool? isActive,
    bool? isFeatured,
    String? ownerId,
    Map<String, dynamic>? extras,
  }) =>
      Place(
        id: id,
        name: name ?? this.name,
        description: description ?? this.description,
        type: type ?? this.type,
        address: address ?? this.address,
        city: city ?? this.city,
        state: state ?? this.state,
        lat: lat ?? this.lat,
        lng: lng ?? this.lng,
        photos: photos ?? this.photos,
        amenities: amenities ?? this.amenities,
        pricePerNight: pricePerNight ?? this.pricePerNight,
        rating: rating,
        reviewCount: reviewCount,
        isActive: isActive ?? this.isActive,
        isFeatured: isFeatured ?? this.isFeatured,
        ownerId: ownerId ?? this.ownerId,
        createdAt: createdAt,
        updatedAt: DateTime.now(),
        extras: extras ?? this.extras,
      );
}
