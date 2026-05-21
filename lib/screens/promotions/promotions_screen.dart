import 'package:flutter/material.dart';
import '../../services/promotions_service.dart';
import '../../models/promotion.dart';
import '../../theme/app_colors.dart';
import '../../widgets/common/page_header.dart';
import '../../widgets/common/status_badge.dart';
import '../../widgets/common/empty_state.dart';
import '../../widgets/common/confirm_dialog.dart';

class PromotionsScreen extends StatefulWidget {
  const PromotionsScreen({super.key});

  @override
  State<PromotionsScreen> createState() => _PromotionsScreenState();
}

class _PromotionsScreenState extends State<PromotionsScreen> {
  final _service = PromotionsService();
  List<Promotion> _promotions = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final snap = await FirestoreHelper.getPromotions();
    setState(() { _promotions = snap; _loading = false; });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PageHeader(
            title: 'Promociones',
            subtitle: '${_promotions.length} promociones',
            actions: [
              ElevatedButton.icon(
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Nueva promoción'),
                onPressed: _showCreateDialog,
              ),
            ],
          ),
          const SizedBox(height: 20),
          Expanded(child: _buildContent()),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_promotions.isEmpty) {
      return EmptyState(
        icon: Icons.local_offer_outlined,
        title: 'Sin promociones',
        subtitle: 'Crea la primera promoción',
        actionLabel: 'Nueva promoción',
        onAction: _showCreateDialog,
      );
    }
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 380,
        childAspectRatio: 1.6,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
      ),
      itemCount: _promotions.length,
      itemBuilder: (_, i) => _promoCard(_promotions[i]),
    );
  }

  Widget _promoCard(Promotion promo) {
    final statusColor = switch (promo.status) {
      PromotionStatus.active => AppColors.success,
      PromotionStatus.scheduled => AppColors.info,
      PromotionStatus.expired => AppColors.textHint,
      PromotionStatus.paused => AppColors.warning,
    };

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppColors.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(promo.title,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    overflow: TextOverflow.ellipsis),
              ),
              StatusBadge(label: promo.status.name, color: statusColor),
            ],
          ),
          const SizedBox(height: 6),
          Text(promo.description,
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
              maxLines: 2, overflow: TextOverflow.ellipsis),
          const Spacer(),
          Row(
            children: [
              const Icon(Icons.calendar_today_outlined, size: 12, color: AppColors.textHint),
              const SizedBox(width: 4),
              Text(
                '${promo.startDate.day}/${promo.startDate.month} - ${promo.endDate.day}/${promo.endDate.month}/${promo.endDate.year}',
                style: const TextStyle(fontSize: 11, color: AppColors.textHint),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.delete_outline, size: 18, color: AppColors.error),
                onPressed: () async {
                  final ok = await ConfirmDialog.show(
                    context,
                    title: 'Eliminar promoción',
                    message: '¿Eliminar "${promo.title}"?',
                  );
                  if (ok && context.mounted) { await _service.delete(promo.id); _load(); }
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showCreateDialog() {
    final titleCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.card,
        title: const Text('Nueva promoción'),
        content: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: titleCtrl, decoration: const InputDecoration(labelText: 'Título')),
              const SizedBox(height: 12),
              TextField(controller: descCtrl, decoration: const InputDecoration(labelText: 'Descripción'), maxLines: 3),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () async {
              await _service.create({
                'title': titleCtrl.text,
                'description': descCtrl.text,
                'type': PromotionType.featured.name,
                'status': PromotionStatus.paused.name,
                'startDate': DateTime.now().toIso8601String(),
                'endDate': DateTime.now().add(const Duration(days: 30)).toIso8601String(),
              });
              if (ctx.mounted) Navigator.pop(ctx);
              _load();
            },
            child: const Text('Crear'),
          ),
        ],
      ),
    );
  }
}

class FirestoreHelper {
  static Future<List<Promotion>> getPromotions() async {
    final service = PromotionsService();
    return service.getActive();
  }
}
