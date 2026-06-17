import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../models/place.dart';
import '../../services/places_service.dart';
import '../../providers/auth_provider.dart';
import '../../providers/places_provider.dart';
import '../../theme/app_colors.dart';
import '../../widgets/common/page_header.dart';
import '../../widgets/common/empty_state.dart';
import '../../config/routes.dart';

/// Cola de aprobación: lugares enviados por usuarios (status='pending').
/// El admin puede revisar, editar, aprobar o rechazar.
class PendientesScreen extends StatelessWidget {
  const PendientesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final service = PlacesService();
    final reviewerUid = context.read<AuthProvider>().user?.uid ?? '';

    return Padding(
      padding: const EdgeInsets.all(24),
      child: StreamBuilder<List<Place>>(
        stream: service.watchPending(),
        builder: (context, snapshot) {
          final items = snapshot.data ?? [];
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              PageHeader(
                title: 'Pendientes',
                subtitle: '${items.length} solicitudes por revisar',
              ),
              const SizedBox(height: 20),
              Expanded(
                child: _buildBody(context, service, reviewerUid, snapshot, items),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    PlacesService service,
    String reviewerUid,
    AsyncSnapshot<List<Place>> snapshot,
    List<Place> items,
  ) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return const Center(child: CircularProgressIndicator());
    }
    if (items.isEmpty) {
      return const EmptyState(
        icon: Icons.inbox_rounded,
        title: 'No hay solicitudes pendientes',
        subtitle: 'Los lugares enviados por usuarios aparecerán aquí',
      );
    }
    return ListView.separated(
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, i) => _card(context, service, reviewerUid, items[i]),
    );
  }

  Widget _card(BuildContext context, PlacesService service, String reviewerUid, Place p) {
    return Container(
      decoration: AppColors.cardDecoration,
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: p.photos.isNotEmpty
                ? Image.network(p.photos.first, width: 90, height: 90, fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _ph())
                : _ph(),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(p.name,
                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                const SizedBox(height: 2),
                Text('${p.type} · ${p.city.isNotEmpty ? '${p.city}, ' : ''}${p.state}',
                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                const SizedBox(height: 6),
                Text(
                  'Enviado por: ${p.submittedByName.isNotEmpty ? p.submittedByName : (p.submittedBy ?? 'usuario')}'
                  '${p.submittedAt != null ? ' · ${_fmt(p.submittedAt!)}' : ''}',
                  style: const TextStyle(color: AppColors.textHint, fontSize: 11),
                ),
                if (p.description.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(p.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                ],
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    OutlinedButton.icon(
                      onPressed: () => context.go('${AppRoutes.placeEdit}/${p.id}'),
                      icon: const Icon(Icons.edit_outlined, size: 16),
                      label: const Text('Editar'),
                    ),
                    ElevatedButton.icon(
                      onPressed: () => _approve(context, service, reviewerUid, p),
                      icon: const Icon(Icons.check, size: 16),
                      label: const Text('Aprobar'),
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.success),
                    ),
                    ElevatedButton.icon(
                      onPressed: () => _reject(context, service, reviewerUid, p),
                      icon: const Icon(Icons.close, size: 16),
                      label: const Text('Rechazar'),
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _approve(
      BuildContext context, PlacesService service, String reviewerUid, Place p) async {
    try {
      await service.approve(p.id, reviewerUid);
      if (context.mounted) {
        context.read<PlacesProvider>().load();
        _snack(context, '"${p.name}" aprobado y publicado.');
      }
    } catch (e) {
      if (context.mounted) _snack(context, 'Error al aprobar: $e', error: true);
    }
  }

  Future<void> _reject(
      BuildContext context, PlacesService service, String reviewerUid, Place p) async {
    final reason = await _askReason(context);
    if (reason == null || reason.trim().isEmpty) return;
    try {
      await service.reject(p.id, reviewerUid, reason.trim());
      if (context.mounted) _snack(context, '"${p.name}" rechazado.');
    } catch (e) {
      if (context.mounted) _snack(context, 'Error al rechazar: $e', error: true);
    }
  }

  Future<String?> _askReason(BuildContext context) {
    final ctrl = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.card,
        title: const Text('Rechazar lugar'),
        content: TextField(
          controller: ctrl,
          maxLines: 3,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Motivo del rechazo (obligatorio)',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, ctrl.text),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Rechazar'),
          ),
        ],
      ),
    );
  }

  void _snack(BuildContext context, String msg, {bool error = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: error ? AppColors.error : AppColors.success,
      behavior: SnackBarBehavior.floating,
    ));
  }

  String _fmt(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

  Widget _ph() => Container(
        width: 90,
        height: 90,
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(Icons.cabin_rounded, color: AppColors.primary, size: 28),
      );
}
