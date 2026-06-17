import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/places_service.dart';
import '../../theme/app_colors.dart';
import '../../config/routes.dart';

class AdminSidebar extends StatelessWidget {
  const AdminSidebar({super.key});

  // Stream compartido del conteo de pendientes (badge en vivo).
  static final Stream<int> _pendingStream =
      PlacesService().pendingCount().asBroadcastStream();

  static const _items = [
    _NavItem(icon: Icons.dashboard_rounded, label: 'Dashboard', route: AppRoutes.dashboard),
    _NavItem(icon: Icons.cabin_rounded, label: 'Lugares', route: AppRoutes.places),
    _NavItem(icon: Icons.pending_actions_rounded, label: 'Pendientes', route: AppRoutes.pendientes),
    _NavItem(icon: Icons.people_rounded, label: 'Usuarios', route: AppRoutes.users),
    _NavItem(icon: Icons.star_rounded, label: 'Reseñas', route: AppRoutes.reviews),
    _NavItem(icon: Icons.flag_rounded, label: 'Reportes', route: AppRoutes.reports),
    _NavItem(icon: Icons.local_offer_rounded, label: 'Promociones', route: AppRoutes.promotions),
    _NavItem(icon: Icons.bar_chart_rounded, label: 'Analíticas', route: AppRoutes.analytics),
    _NavItem(icon: Icons.campaign_rounded, label: 'Anuncios Popup', route: AppRoutes.popupAds),
    _NavItem(icon: Icons.monetization_on_rounded, label: 'AdMob', route: AppRoutes.ads),
    _NavItem(icon: Icons.settings_rounded, label: 'Configuración', route: AppRoutes.settings),
  ];

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    final auth = context.read<AuthProvider>();

    return Container(
      width: 240,
      decoration: const BoxDecoration(
        gradient: AppColors.sidebarGradient,
        border: Border(right: BorderSide(color: AppColors.border)),
      ),
      child: Column(
        children: [
          _buildLogo(),
          const Divider(color: AppColors.border, height: 1),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: _items.length,
              itemBuilder: (_, i) {
                final item = _items[i];
                final active = location.startsWith(item.route);
                return _NavTile(
                  item: item,
                  active: active,
                  badgeStream: item.route == AppRoutes.pendientes ? _pendingStream : null,
                );
              },
            ),
          ),
          const Divider(color: AppColors.border, height: 1),
          _buildUserTile(context, auth),
        ],
      ),
    );
  }

  Widget _buildLogo() {
    return Container(
      height: 70,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.cabin_rounded, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          const Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Cabin', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              Text('Admin Panel', style: TextStyle(color: AppColors.textSecondary, fontSize: 11)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUserTile(BuildContext context, AuthProvider auth) {
    return InkWell(
      onTap: () => context.go(AppRoutes.profile),
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: AppColors.primary.withValues(alpha: 0.2),
              backgroundImage: auth.user?.photoURL != null
                  ? NetworkImage(auth.user!.photoURL!)
                  : null,
              child: auth.user?.photoURL == null
                  ? Text(
                      auth.displayName.isNotEmpty ? auth.displayName[0].toUpperCase() : 'A',
                      style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
                    )
                  : null,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(auth.displayName, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                      overflow: TextOverflow.ellipsis),
                  Text(auth.role, style: const TextStyle(color: AppColors.textSecondary, fontSize: 11)),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.logout_rounded, size: 18, color: AppColors.textHint),
              onPressed: () => auth.signOut(),
              tooltip: 'Cerrar sesión',
            ),
          ],
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final String label;
  final String route;
  const _NavItem({required this.icon, required this.label, required this.route});
}

class _NavTile extends StatefulWidget {
  final _NavItem item;
  final bool active;
  final Stream<int>? badgeStream;
  const _NavTile({required this.item, required this.active, this.badgeStream});

  @override
  State<_NavTile> createState() => _NavTileState();
}

class _NavTileState extends State<_NavTile> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final active = widget.active;
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: () => context.go(widget.item.route),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: active
                ? AppColors.primary.withValues(alpha: 0.15)
                : _hovered
                    ? AppColors.hover
                    : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            border: active
                ? Border.all(color: AppColors.primary.withValues(alpha: 0.3))
                : null,
          ),
          child: Row(
            children: [
              Icon(
                widget.item.icon,
                size: 20,
                color: active ? AppColors.primary : AppColors.textSecondary,
              ),
              const SizedBox(width: 12),
              Text(
                widget.item.label,
                style: TextStyle(
                  color: active ? AppColors.primary : AppColors.textSecondary,
                  fontWeight: active ? FontWeight.w600 : FontWeight.normal,
                  fontSize: 14,
                ),
              ),
              if (widget.badgeStream != null) ...[
                const Spacer(),
                StreamBuilder<int>(
                  stream: widget.badgeStream,
                  builder: (_, snap) {
                    final count = snap.data ?? 0;
                    if (count <= 0) return const SizedBox.shrink();
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.error,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        count > 99 ? '99+' : '$count',
                        style: const TextStyle(
                            color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                    );
                  },
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
