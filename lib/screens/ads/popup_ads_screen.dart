import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../config/routes.dart';
import '../../models/popup_ad.dart';
import '../../services/popup_ads_service.dart';
import '../../theme/app_colors.dart';
import '../../widgets/common/confirm_dialog.dart';
import '../../widgets/common/empty_state.dart';
import '../../widgets/common/page_header.dart';
import '../../widgets/common/status_badge.dart';

class PopupAdsScreen extends StatefulWidget {
  const PopupAdsScreen({super.key});

  @override
  State<PopupAdsScreen> createState() => _PopupAdsScreenState();
}

class _PopupAdsScreenState extends State<PopupAdsScreen> {
  final _service = PopupAdsService();
  List<PopupAd> _all = [];
  List<PopupAd> _filtered = [];
  bool _loading = true;
  String _filter = 'todos';

  static const _filters = ['todos', 'activo', 'programado', 'expirado', 'pausado'];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final list = await _service.getAll();
    if (mounted) {
      setState(() {
        _all = list;
        _applyFilter();
        _loading = false;
      });
    }
  }

  void _applyFilter() {
    if (_filter == 'todos') {
      _filtered = List.from(_all);
    } else {
      _filtered = _all
          .where((p) => p.computedStatus.name == _filter)
          .toList();
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
            title: 'Anuncios Popup',
            subtitle: '${_all.length} anuncios',
            actions: [
              FilledButton.icon(
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Nuevo anuncio'),
                onPressed: () =>
                    context.go(AppRoutes.popupAdNew),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildFilters(),
          const SizedBox(height: 16),
          Expanded(child: _buildContent()),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return Wrap(
      spacing: 8,
      children: _filters.map((f) {
        final active = _filter == f;
        return ChoiceChip(
          label: Text(f[0].toUpperCase() + f.substring(1)),
          selected: active,
          selectedColor: AppColors.primary.withValues(alpha: 0.2),
          labelStyle: TextStyle(
            color: active ? AppColors.primary : AppColors.textSecondary,
            fontWeight: active ? FontWeight.w600 : FontWeight.normal,
          ),
          side: BorderSide(
            color: active
                ? AppColors.primary.withValues(alpha: 0.5)
                : AppColors.border,
          ),
          backgroundColor: AppColors.card,
          onSelected: (_) {
            setState(() {
              _filter = f;
              _applyFilter();
            });
          },
        );
      }).toList(),
    );
  }

  Widget _buildContent() {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_filtered.isEmpty) {
      return EmptyState(
        icon: Icons.campaign_outlined,
        title: 'Sin anuncios popup',
        subtitle: 'Crea el primer anuncio popup',
        actionLabel: 'Nuevo anuncio',
        onAction: () => context.go(AppRoutes.popupAdNew),
      );
    }
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 340,
        childAspectRatio: 0.72,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
      ),
      itemCount: _filtered.length,
      itemBuilder: (_, i) => _popupCard(_filtered[i]),
    );
  }

  Widget _popupCard(PopupAd popup) {
    final status = popup.computedStatus;
    final statusColor = switch (status) {
      PopupAdStatus.active => AppColors.success,
      PopupAdStatus.scheduled => AppColors.info,
      PopupAdStatus.expired => AppColors.textHint,
      PopupAdStatus.paused => AppColors.warning,
    };
    final fmt = DateFormat('dd/MM/yy');

    return Container(
      decoration: AppColors.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image preview
          Expanded(
            child: ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(12)),
              child: popup.imageUrl.isEmpty
                  ? Container(
                      color: AppColors.hover,
                      child: const Center(
                        child: Icon(Icons.image_outlined,
                            color: AppColors.textHint, size: 40),
                      ),
                    )
                  : CachedNetworkImage(
                      imageUrl: popup.imageUrl,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      errorWidget: (_, __, ___) => Container(
                        color: AppColors.hover,
                        child: const Icon(Icons.broken_image_outlined,
                            color: AppColors.textHint, size: 32),
                      ),
                    ),
            ),
          ),
          // Info
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        popup.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: AppColors.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 6),
                    StatusBadge(label: status.name, color: statusColor),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '${fmt.format(popup.startDate)} → ${fmt.format(popup.endDate)}',
                  style: const TextStyle(
                      color: AppColors.textHint, fontSize: 11),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    _statChip(Icons.visibility_outlined,
                        '${popup.totalImpressions}', AppColors.info),
                    const SizedBox(width: 6),
                    _statChip(Icons.ads_click_rounded,
                        '${popup.ctr.toStringAsFixed(1)}%', AppColors.success),
                  ],
                ),
                const SizedBox(height: 8),
                _buildActions(popup),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _statChip(IconData icon, String value, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: color),
        const SizedBox(width: 3),
        Text(value,
            style: TextStyle(
                color: color,
                fontSize: 11,
                fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _buildActions(PopupAd popup) {
    return Row(
      children: [
        _actionBtn(
          Icons.edit_outlined,
          AppColors.primary,
          () => context.go('${AppRoutes.popupAdEdit}/${popup.id}'),
          'Editar',
        ),
        const SizedBox(width: 4),
        _actionBtn(
          Icons.bar_chart_rounded,
          AppColors.info,
          () => context.go('${AppRoutes.popupAdStats}/${popup.id}'),
          'Stats',
        ),
        const SizedBox(width: 4),
        _actionBtn(
          popup.active
              ? Icons.pause_circle_outline
              : Icons.play_circle_outline,
          popup.active ? AppColors.warning : AppColors.success,
          () async {
            await _service.setActive(popup.id,
                active: !popup.active);
            _load();
          },
          popup.active ? 'Pausar' : 'Activar',
        ),
        const SizedBox(width: 4),
        _actionBtn(
          Icons.copy_outlined,
          AppColors.textSecondary,
          () async {
            await _service.duplicate(popup);
            _load();
          },
          'Duplicar',
        ),
        const SizedBox(width: 4),
        _actionBtn(
          Icons.delete_outline,
          AppColors.error,
          () async {
            final ok = await ConfirmDialog.show(
              context,
              title: 'Eliminar anuncio',
              message:
                  '¿Eliminar "${popup.title}"? Se borrará también la imagen.',
            );
            if (ok && context.mounted) {
              await _service.delete(popup.id);
              _load();
            }
          },
          'Eliminar',
        ),
      ],
    );
  }

  Widget _actionBtn(
      IconData icon, Color color, VoidCallback onTap, String tooltip) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: Icon(icon, size: 18, color: color),
        ),
      ),
    );
  }
}
