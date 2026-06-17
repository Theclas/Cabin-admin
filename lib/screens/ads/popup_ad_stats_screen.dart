import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../config/app_config.dart';
import '../../config/routes.dart';
import '../../models/popup_ad.dart';
import '../../services/popup_ads_service.dart';
import '../../theme/app_colors.dart';
import '../../widgets/common/kpi_card.dart';
import '../../widgets/common/page_header.dart';

class PopupAdStatsScreen extends StatefulWidget {
  final String popupId;
  const PopupAdStatsScreen({super.key, required this.popupId});

  @override
  State<PopupAdStatsScreen> createState() => _PopupAdStatsScreenState();
}

class _PopupAdStatsScreenState extends State<PopupAdStatsScreen> {
  final _service = PopupAdsService();
  PopupAd? _popup;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final popup = await _service.getById(widget.popupId);
    if (mounted) {
      setState(() {
        _popup = popup;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PageHeader(
            title: _popup != null
                ? 'Estadísticas: ${_popup!.title}'
                : 'Estadísticas',
            subtitle: 'Rendimiento del anuncio popup',
            actions: [
              OutlinedButton.icon(
                icon: const Icon(Icons.arrow_back, size: 16),
                label: const Text('Volver'),
                onPressed: () => context.go(AppRoutes.popupAds),
              ),
              const SizedBox(width: 12),
              OutlinedButton.icon(
                icon: const Icon(Icons.edit_outlined, size: 16),
                label: const Text('Editar'),
                onPressed: () => context
                    .go('${AppRoutes.popupAdEdit}/${widget.popupId}'),
              ),
            ],
          ),
          const SizedBox(height: 24),
          if (_loading)
            const Center(child: CircularProgressIndicator())
          else if (_popup == null)
            const Center(
              child: Text('Anuncio no encontrado',
                  style: TextStyle(color: AppColors.textSecondary)),
            )
          else
            Expanded(child: _buildContent()),
        ],
      ),
    );
  }

  Widget _buildContent() {
    final p = _popup!;
    final fmt = DateFormat('dd/MM/yyyy');

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // KPI row
          Row(
            children: [
              Expanded(
                child: KpiCard(
                  title: 'Impresiones',
                  value: '${p.totalImpressions}',
                  icon: Icons.visibility_outlined,
                  color: AppColors.info,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: KpiCard(
                  title: 'Clics',
                  value: '${p.totalClicks}',
                  icon: Icons.ads_click_rounded,
                  color: AppColors.success,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: KpiCard(
                  title: 'CTR',
                  value: '${p.ctr.toStringAsFixed(1)}%',
                  icon: Icons.percent_rounded,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: KpiCard(
                  title: 'Cerrados',
                  value: '${p.totalDismissed}',
                  icon: Icons.close_rounded,
                  color: AppColors.warning,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Details card
          _card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Detalles del anuncio',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: AppColors.textPrimary)),
                const SizedBox(height: 16),
                _detailRow('ID', p.id),
                _detailRow('Título', p.title),
                _detailRow('Estado', p.computedStatus.name),
                _detailRow('Acción', p.actionType.name),
                if (p.actionLabel != null)
                  _detailRow('Destino', p.actionLabel!),
                _detailRow('Pantallas', p.showOnScreens.join(', ')),
                _detailRow('Inicio', fmt.format(p.startDate)),
                _detailRow('Fin', fmt.format(p.endDate)),
                _detailRow('Prioridad', '${p.priority}'),
                _detailRow('Max/usuario', '${p.maxDisplaysPerUser} veces'),
                _detailRow('Retraso', '${p.displayDelaySeconds} s'),
                _detailRow('Cierre mín.', '${p.minTimeBeforeClose} s'),
                _detailRow('Creado', fmt.format(p.createdAt)),
              ],
            ),
          ),
          const SizedBox(height: 24),
          // Live stats from Firestore stream
          _buildLiveStats(),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildLiveStats() {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection(AppConfig.colPopupAds)
          .doc(widget.popupId)
          .snapshots(),
      builder: (_, snap) {
        if (!snap.hasData) return const SizedBox.shrink();
        final d = snap.data!.data() as Map<String, dynamic>?;
        if (d == null) return const SizedBox.shrink();

        final impressions = (d['totalImpressions'] as num?)?.toInt() ?? 0;
        final clicks = (d['totalClicks'] as num?)?.toInt() ?? 0;
        final dismissed = (d['totalDismissed'] as num?)?.toInt() ?? 0;
        final ctr =
            impressions == 0 ? 0.0 : clicks / impressions * 100;

        return _card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text('Datos en tiempo real',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: AppColors.textPrimary)),
                  const SizedBox(width: 8),
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: AppColors.success,
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              if (impressions > 0)
                SizedBox(
                  height: 160,
                  child: BarChart(
                    BarChartData(
                      alignment: BarChartAlignment.spaceAround,
                      maxY: (impressions * 1.2).ceilToDouble(),
                      titlesData: FlTitlesData(
                        leftTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false)),
                        rightTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false)),
                        topTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false)),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (v, _) {
                              final labels = [
                                'Impresiones',
                                'Clics',
                                'Cerrados'
                              ];
                              return Text(labels[v.toInt()],
                                  style: const TextStyle(
                                      fontSize: 10,
                                      color: AppColors.textHint));
                            },
                          ),
                        ),
                      ),
                      gridData: const FlGridData(show: false),
                      borderData: FlBorderData(show: false),
                      barGroups: [
                        _bar(0, impressions.toDouble(), AppColors.info),
                        _bar(1, clicks.toDouble(), AppColors.success),
                        _bar(2, dismissed.toDouble(), AppColors.warning),
                      ],
                    ),
                  ),
                )
              else
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Center(
                    child: Text(
                      'Sin datos aún — los stats aparecen cuando\nla app muestre este popup.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: AppColors.textHint, fontSize: 13),
                    ),
                  ),
                ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _miniStat('${impressions}', 'Impresiones', AppColors.info),
                  _miniStat('${clicks}', 'Clics', AppColors.success),
                  _miniStat(
                      '${ctr.toStringAsFixed(1)}%', 'CTR', AppColors.primary),
                  _miniStat('${dismissed}', 'Cerrados', AppColors.warning),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  BarChartGroupData _bar(int x, double y, Color color) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          color: color,
          width: 32,
          borderRadius: BorderRadius.circular(4),
        ),
      ],
    );
  }

  Widget _miniStat(String value, String label, Color color) {
    return Column(
      children: [
        Text(value,
            style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 18)),
        Text(label,
            style: const TextStyle(
                color: AppColors.textHint, fontSize: 11)),
      ],
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(label,
                style: const TextStyle(
                    color: AppColors.textHint, fontSize: 12)),
          ),
          Expanded(
            child: Text(value,
                style: const TextStyle(
                    color: AppColors.textSecondary, fontSize: 12)),
          ),
        ],
      ),
    );
  }

  Widget _card({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppColors.cardDecoration,
      child: child,
    );
  }
}
