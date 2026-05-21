import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/reports_service.dart';
import '../../providers/auth_provider.dart';
import '../../models/report.dart';
import '../../theme/app_colors.dart';
import '../../widgets/common/page_header.dart';
import '../../widgets/common/empty_state.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> with SingleTickerProviderStateMixin {
  final _service = ReportsService();
  late TabController _tabs;
  List<Report> _all = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 4, vsync: this);
    _load();
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  Future<void> _load() => _loadAll();

  Future<void> _loadAll() async {
    setState(() => _loading = true);
    _all = await _service.getPending();
    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PageHeader(
            title: 'Reportes',
            subtitle: '${_all.length} reportes pendientes',
            actions: [
              IconButton(icon: const Icon(Icons.refresh), onPressed: _loadAll, color: AppColors.textSecondary),
            ],
          ),
          const SizedBox(height: 16),
          TabBar(
            controller: _tabs,
            tabs: const [
              Tab(text: 'Pendientes'),
              Tab(text: 'En revisión'),
              Tab(text: 'Resueltos'),
              Tab(text: 'Descartados'),
            ],
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.textSecondary,
            indicatorColor: AppColors.primary,
          ),
          const SizedBox(height: 16),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : TabBarView(
                    controller: _tabs,
                    children: [
                      _reportList(_all),
                      const EmptyState(icon: Icons.pending, title: 'Sin reportes en revisión'),
                      const EmptyState(icon: Icons.check_circle_outline, title: 'Sin reportes resueltos'),
                      const EmptyState(icon: Icons.cancel_outlined, title: 'Sin reportes descartados'),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _reportList(List<Report> reports) {
    if (reports.isEmpty) {
      return const EmptyState(icon: Icons.flag_outlined, title: 'Sin reportes', subtitle: '¡Todo en orden!');
    }
    return ListView.separated(
      itemCount: reports.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (_, i) => _reportCard(reports[i]),
    );
  }

  Widget _reportCard(Report report) {
    final auth = context.read<AuthProvider>();
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppColors.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.warning.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(report.type.name.toUpperCase(),
                    style: const TextStyle(color: AppColors.warning, fontSize: 11, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(width: 8),
              Text(report.reason, style: const TextStyle(fontWeight: FontWeight.w600)),
              const Spacer(),
              Text(
                '${report.createdAt.day}/${report.createdAt.month}/${report.createdAt.year}',
                style: const TextStyle(color: AppColors.textHint, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text('Reportado: ${report.targetName}', style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
          Text('Por: ${report.reporterName}', style: const TextStyle(color: AppColors.textHint, fontSize: 12)),
          if (report.description != null) ...[
            const SizedBox(height: 6),
            Text(report.description!, style: const TextStyle(fontSize: 13)),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              OutlinedButton(
                onPressed: () => _service.dismiss(report.id, auth.user?.uid ?? ''),
                style: OutlinedButton.styleFrom(foregroundColor: AppColors.textSecondary),
                child: const Text('Descartar'),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () => _resolve(report, auth),
                child: const Text('Resolver'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _resolve(Report report, AuthProvider auth) async {
    final ctrl = TextEditingController();
    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.card,
        title: const Text('Resolver reporte'),
        content: TextField(
          controller: ctrl,
          decoration: const InputDecoration(labelText: 'Resolución / acción tomada'),
          maxLines: 3,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () async {
              await _service.resolve(report.id, auth.user?.uid ?? '', ctrl.text);
              if (ctx.mounted) Navigator.pop(ctx);
              _loadAll();
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }
}
