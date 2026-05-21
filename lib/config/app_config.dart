class AppConfig {
  static const String appName = 'Cabin Admin';
  static const String appVersion = '1.0.0';
  static const String copyright = '© 2025 Cabin. Todos los derechos reservados.';

  // Roles
  static const String roleUser = 'user';
  static const String roleModerator = 'moderator';
  static const String roleAdmin = 'admin';
  static const String roleSuperAdmin = 'superadmin';
  static const List<String> adminRoles = [roleAdmin, roleSuperAdmin];

  // Firestore collections
  static const String colUsers = 'users';
  static const String colPlaces = 'places';
  static const String colReviews = 'reviews';
  static const String colReports = 'reports';
  static const String colPromotions = 'promotions';
  static const String colNotifications = 'notifications';
  static const String colLegal = 'legal';
  static const String colConfig = 'config';
  static const String colAds = 'ads_config';
  static const String colAdminLogs = 'admin_logs';

  // Storage paths
  static const String storagePlaces = 'places';
  static const String storagePromotions = 'promotions';
  static const String storageUsers = 'users';

  // Pagination
  static const int pageSize = 20;

  // Max photo uploads
  static const int maxPlacePhotos = 10;
  static const double maxPhotoSizeMb = 5.0;

  // México states
  static const List<String> mexicoStates = [
    'Aguascalientes', 'Baja California', 'Baja California Sur', 'Campeche',
    'Chiapas', 'Chihuahua', 'Ciudad de México', 'Coahuila', 'Colima',
    'Durango', 'Estado de México', 'Guanajuato', 'Guerrero', 'Hidalgo',
    'Jalisco', 'Michoacán', 'Morelos', 'Nayarit', 'Nuevo León', 'Oaxaca',
    'Puebla', 'Querétaro', 'Quintana Roo', 'San Luis Potosí', 'Sinaloa',
    'Sonora', 'Tabasco', 'Tamaulipas', 'Tlaxcala', 'Veracruz',
    'Yucatán', 'Zacatecas',
  ];

  static const List<String> amenitiesList = [
    'WiFi', 'Estacionamiento', 'Jacuzzi', 'TV', 'Aire Acondicionado',
    'Calefacción', 'Servibar', 'Piscina', 'Mascotas permitidas',
    'Room Service', 'Cocina', 'Chimenea', 'Terraza', 'BBQ', 'Sauna',
    'Spa', 'Gimnasio', 'Bar', 'Restaurante', 'Lavandería',
    'Caja fuerte', 'Toallas', 'Sábanas', 'Agua caliente',
  ];
}
