import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/dashboard_provider.dart';
import '../../theme/app_colors.dart';
import '../../widgets/common/kpi_card.dart';
import '../../widgets/common/page_header.dart';
import '../../config/routes.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DashboardProvider>().load();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DashboardProvider>(
      builder: (context, provider, _) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const PageHeader(
                title: 'Dashboard',
                subtitle: 'Resumen general del sistema',
              ),
              const SizedBox(height: 24),
              if (provider.loading)
                const Center(child: CircularProgressIndicator())
              else ...[
                _buildKpis(context, provider),
                const SizedBox(height: 24),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: _buildRecentPlaces(provider)),
                    const SizedBox(width: 16),
                    Expanded(child: _buildTopRated(provider)),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: _buildRecentUsers(provider)),
                    const SizedBox(width: 16),
                    Expanded(child: _buildByState(provider)),
                  ],
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildKpis(BuildContext context, DashboardProvider p) {
    final kpis = p.kpis;
    return GridView.count(
      crossAxisCount: 4,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 1.4,
      children: [
        KpiCard(
          title: 'Total Lugares',
          value: '${kpis['totalPlaces'] ?? 0}',
          icon: Icons.cabin_rounded,
          color: AppColors.primary,
          onTap: () => context.go(AppRoutes.places),
        ),
        KpiCard(
          title: 'Usuarios',
          value: '${kpis['totalUsers'] ?? 0}',
          icon: Icons.people_rounded,
          color: AppColors.info,
          onTap: () => context.go(AppRoutes.users),
        ),
        KpiCard(
          title: 'Reseñas',
          value: '${kpis['totalReviews'] ?? 0}',
          icon: Icons.star_rounded,
          color: AppColors.warning,
          onTap: () => context.go(AppRoutes.reviews),
        ),
        KpiCard(
          title: 'Reportes Pendientes',
          value: '${kpis['pendingReports'] ?? 0}',
          icon: Icons.flag_rounded,
          color: kpis['pendingReports'] != null && kpis['pendingReports'] > 0
              ? AppColors.error
              : AppColors.success,
          onTap: () => context.go(AppRoutes.reports),
        ),
      ],
    );
  }

  Widget _buildRecentPlaces(DashboardProvider p) {
    return _Card(
      title: 'Lugares recientes',
      child: Column(
        children: p.recentPlaces.map((place) {
          return ListTile(
            dense: true,
            leading: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.cabin_rounded, color: AppColors.primary, size: 18),
            ),
            title: Text(place['name'] ?? '', style: const TextStyle(fontSize: 13)),
            subtitle: Text(place['city'] ?? '', style: const TextStyle(color: AppColors.textSecondary, fontSize: 11)),
            trailing: Text(
              '\$${((place['pricePerNight'] as num?)?.toStringAsFixed(0)) ?? '0'}',
              style: const TextStyle(color: AppColors.success, fontSize: 12, fontWeight: FontWeight.w600),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTopRated(DashboardProvider p) {
    return _Card(
      title: 'Mejor calificados',
      child: Column(
        children: p.topRated.map((place) {
          final rating = (place['rating'] as num?)?.toDouble() ?? 0;
          return ListTile(
            dense: true,
            leading: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.warning.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.star_rounded, color: AppColors.warning, size: 18),
            ),
            title: Text(place['name'] ?? '', style: const TextStyle(fontSize: 13)),
            subtitle: Text(place['city'] ?? '', style: const TextStyle(color: AppColors.textSecondary, fontSize: 11)),
            trailing: Text(
              rating.toStringAsFixed(1),
              style: const TextStyle(color: AppColors.warning, fontWeight: FontWeight.bold),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildRecentUsers(DashboardProvider p) {
    return _Card(
      title: 'Usuarios recientes',
      child: Column(
        children: p.recentUsers.map((user) {
          return ListTile(
            dense: true,
            leading: CircleAvatar(
              radius: 18,
              backgroundColor: AppColors.secondary.withValues(alpha: 0.2),
              child: Text(
                (user['displayName'] ?? 'U').toString().isNotEmpty
                    ? user['displayName'].toString()[0].toUpperCase()
                    : 'U',
                style: const TextStyle(color: AppColors.secondary, fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ),
            title: Text(user['displayName'] ?? '', style: const TextStyle(fontSize: 13)),
            subtitle: Text(user['email'] ?? '', style: const TextStyle(color: AppColors.textSecondary, fontSize: 11)),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildByState(DashboardProvider p) {
    return _Card(
      title: 'Lugares por estado',
      child: Column(
        children: p.byState.take(6).map((item) {
          final count = item['count'] as int;
          final maxCount = p.byState.isNotEmpty ? (p.byState.first['count'] as int) : 1;
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              children: [
                SizedBox(
                  width: 100,
                  child: Text(
                    item['state'] as String,
                    style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: count / maxCount,
                      backgroundColor: AppColors.border,
                      valueColor: const AlwaysStoppedAnimation(AppColors.primary),
                      minHeight: 8,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text('$count', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _Card extends StatelessWidget {
  final String title;
  final Widget child;
  const _Card({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppColors.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}
