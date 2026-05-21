import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../providers/dashboard_provider.dart';
import '../../theme/app_colors.dart';
import '../../widgets/common/page_header.dart';
import '../../widgets/common/kpi_card.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
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
      builder: (context, p, _) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const PageHeader(title: 'Analíticas', subtitle: 'Métricas de la plataforma'),
              const SizedBox(height: 24),
              if (p.loading)
                const Center(child: CircularProgressIndicator())
              else ...[
                GridView.count(
                  crossAxisCount: 4,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 1.4,
                  children: [
                    KpiCard(
                      title: 'Total lugares',
                      value: '${p.kpis['totalPlaces'] ?? 0}',
                      icon: Icons.cabin_rounded,
                      color: AppColors.primary,
                    ),
                    KpiCard(
                      title: 'Usuarios',
                      value: '${p.kpis['totalUsers'] ?? 0}',
                      icon: Icons.people_rounded,
                      color: AppColors.info,
                    ),
                    KpiCard(
                      title: 'Reseñas',
                      value: '${p.kpis['totalReviews'] ?? 0}',
                      icon: Icons.star_rounded,
                      color: AppColors.warning,
                    ),
                    KpiCard(
                      title: 'Reportes pendientes',
                      value: '${p.kpis['pendingReports'] ?? 0}',
                      icon: Icons.flag_rounded,
                      color: AppColors.error,
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: _buildPieChart(p)),
                    const SizedBox(width: 16),
                    Expanded(child: _buildBarChart(p)),
                  ],
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildPieChart(DashboardProvider p) {
    final data = p.byState.take(6).toList();
    if (data.isEmpty) return const SizedBox.shrink();

    final colors = [
      AppColors.primary, AppColors.secondary, AppColors.accent,
      AppColors.info, AppColors.success, AppColors.warning,
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppColors.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Distribución por provincia', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          const SizedBox(height: 16),
          SizedBox(
            height: 220,
            child: Row(
              children: [
                Expanded(
                  child: PieChart(
                    PieChartData(
                      sections: data.asMap().entries.map((e) {
                        final count = e.value['count'] as int;
                        return PieChartSectionData(
                          value: count.toDouble(),
                          color: colors[e.key % colors.length],
                          radius: 80,
                          showTitle: false,
                        );
                      }).toList(),
                      sectionsSpace: 2,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: data.asMap().entries.map((e) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 3),
                      child: Row(
                        children: [
                          Container(
                            width: 10, height: 10,
                            decoration: BoxDecoration(
                              color: colors[e.key % colors.length],
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '${e.value['state']} (${e.value['count']})',
                            style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBarChart(DashboardProvider p) {
    final data = p.topRated;
    if (data.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppColors.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Top lugares por rating', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          const SizedBox(height: 16),
          SizedBox(
            height: 220,
            child: BarChart(
              BarChartData(
                maxY: 5,
                barGroups: data.asMap().entries.map((e) {
                  final rating = (e.value['rating'] as num?)?.toDouble() ?? 0;
                  return BarChartGroupData(
                    x: e.key,
                    barRods: [
                      BarChartRodData(
                        toY: rating,
                        gradient: const LinearGradient(
                          colors: [AppColors.primary, AppColors.secondary],
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                        ),
                        width: 20,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ],
                  );
                }).toList(),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (_) => const FlLine(color: AppColors.border, strokeWidth: 1),
                ),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: true, reservedSize: 30,
                        getTitlesWidget: (v, _) => Text(v.toStringAsFixed(0), style: const TextStyle(fontSize: 10, color: AppColors.textHint))),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (v, _) {
                        final idx = v.toInt();
                        if (idx >= data.length) return const SizedBox.shrink();
                        final name = (data[idx]['name'] as String?) ?? '';
                        return Text(
                          name.length > 8 ? '${name.substring(0, 8)}...' : name,
                          style: const TextStyle(fontSize: 9, color: AppColors.textHint),
                        );
                      },
                    ),
                  ),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
