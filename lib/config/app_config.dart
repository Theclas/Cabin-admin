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
  static const String colPopupAds = 'popup_ads';
  static const String colAdminLogs = 'admin_logs';

  // Storage paths
  static const String storagePlaces = 'places';
  static const String storagePromotions = 'promotions';
  static const String storageUsers = 'users';
  static const String storagePopupAds = 'popup_ads';

  // Pagination
  static const int pageSize = 20;

  // Max photo uploads
  static const int maxPlacePhotos = 10;
  static const double maxPhotoSizeMb = 5.0;

  // Provincias de República Dominicana (31 provincias + Distrito Nacional)
  static const List<String> dominicanaProvinces = [
    'Azua', 'Baoruco', 'Barahona', 'Dajabón', 'Distrito Nacional',
    'Duarte', 'Elías Piña', 'El Seibo', 'Espaillat', 'Hato Mayor',
    'Hermanas Mirabal', 'Independencia', 'La Altagracia', 'La Romana',
    'La Vega', 'María Trinidad Sánchez', 'Monseñor Nouel', 'Monte Cristi',
    'Monte Plata', 'Pedernales', 'Peravia', 'Puerto Plata', 'Samaná',
    'San Cristóbal', 'San José de Ocoa', 'San Juan',
    'San Pedro de Macorís', 'Sánchez Ramírez', 'Santiago',
    'Santiago Rodríguez', 'Santo Domingo', 'Valverde',
  ];

  // Principales ciudades/municipios de RD para datos y búsquedas
  static const List<String> dominicananCities = [
    'Santo Domingo', 'Santiago de los Caballeros', 'Punta Cana', 'Bávaro',
    'La Romana', 'Puerto Plata', 'San Pedro de Macorís', 'Boca Chica',
    'Jarabacoa', 'Constanza', 'Samaná', 'Las Terrenas', 'Bayahíbe',
    'San Francisco de Macorís', 'Higüey', 'Moca', 'Bonao', 'San Cristóbal',
  ];

  static const List<String> amenitiesList = [
    'WiFi', 'Estacionamiento', 'Jacuzzi', 'TV', 'Aire Acondicionado',
    'Calefacción', 'Servibar', 'Piscina', 'Mascotas permitidas',
    'Room Service', 'Cocina', 'Chimenea', 'Terraza', 'BBQ', 'Sauna',
    'Spa', 'Gimnasio', 'Bar', 'Restaurante', 'Lavandería',
    'Caja fuerte', 'Toallas', 'Sábanas', 'Agua caliente',
  ];
}
