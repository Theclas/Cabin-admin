import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/places_provider.dart';
import '../../models/place.dart';
import '../../theme/app_colors.dart';
import '../../widgets/common/page_header.dart';
import '../../widgets/common/status_badge.dart';
import '../../widgets/common/empty_state.dart';
import '../../widgets/common/confirm_dialog.dart';
import '../../config/routes.dart';
import '../../config/app_config.dart';

class PlacesScreen extends StatefulWidget {
  const PlacesScreen({super.key});

  @override
  State<PlacesScreen> createState() => _PlacesScreenState();
}

class _PlacesScreenState extends State<PlacesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PlacesProvider>().load();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PlacesProvider>(
      builder: (context, provider, _) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              PageHeader(
                title: 'Lugares',
                subtitle: '${provider.places.length} resultados',
                actions: [
                  ElevatedButton.icon(
                    onPressed: () => context.go(AppRoutes.placeNew),
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('Nuevo lugar'),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _buildFilters(provider),
              const SizedBox(height: 16),
              Expanded(child: _buildTable(context, provider)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFilters(PlacesProvider p) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            onChanged: p.setSearch,
            decoration: InputDecoration(
              hintText: 'Buscar por nombre, ciudad o provincia...',
              prefixIcon: const Icon(Icons.search, size: 18),
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(vertical: 10),
              suffixIcon: p.search.isNotEmpty
                  ? IconButton(icon: const Icon(Icons.clear, size: 16), onPressed: () => p.setSearch(''))
                  : null,
            ),
          ),
        ),
        const SizedBox(width: 12),
        DropdownButton<String>(
          value: p.filterState.isEmpty ? null : p.filterState,
          hint: const Text('Provincia', style: TextStyle(color: AppColors.textHint)),
          dropdownColor: AppColors.card,
          underline: const SizedBox(),
          items: [
            const DropdownMenuItem(value: '', child: Text('Todas las provincias')),
            ...AppConfig.dominicanaProvinces.map(
              (s) => DropdownMenuItem(value: s, child: Text(s)),
            ),
          ],
          onChanged: (v) => p.setFilterState(v ?? ''),
        ),
        const SizedBox(width: 12),
        DropdownButton<bool?>(
          value: p.filterActive,
          hint: const Text('Estado', style: TextStyle(color: AppColors.textHint)),
          dropdownColor: AppColors.card,
          underline: const SizedBox(),
          items: const [
            DropdownMenuItem(value: null, child: Text('Todos')),
            DropdownMenuItem(value: true, child: Text('Activos')),
            DropdownMenuItem(value: false, child: Text('Inactivos')),
          ],
          onChanged: (v) => p.setFilterActive(v),
        ),
        const SizedBox(width: 8),
        IconButton(
          icon: const Icon(Icons.refresh, color: AppColors.textSecondary),
          onPressed: p.load,
          tooltip: 'Recargar',
        ),
      ],
    );
  }

  Widget _buildTable(BuildContext context, PlacesProvider p) {
    if (p.status == LoadStatus.loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (p.places.isEmpty) {
      return EmptyState(
        icon: Icons.cabin_rounded,
        title: 'No hay lugares',
        subtitle: 'Agrega el primer lugar',
        actionLabel: 'Nuevo lugar',
        onAction: () => context.go(AppRoutes.placeNew),
      );
    }

    return Container(
      decoration: AppColors.cardDecoration,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: SingleChildScrollView(
          child: Table(
            columnWidths: const {
              0: FlexColumnWidth(3),
              1: FlexColumnWidth(2),
              2: FlexColumnWidth(1.5),
              3: FlexColumnWidth(1),
              4: FlexColumnWidth(1),
              5: FlexColumnWidth(1.5),
            },
            children: [
              _tableHeader(),
              ...p.places.map((place) => _tableRow(context, p, place)),
            ],
          ),
        ),
      ),
    );
  }

  TableRow _tableHeader() {
    return TableRow(
      decoration: const BoxDecoration(color: AppColors.hover),
      children: ['Nombre', 'Ciudad / Provincia', 'Precio/noche', 'Rating', 'Estado', 'Acciones']
          .map((h) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Text(h,
                    style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary)),
              ))
          .toList(),
    );
  }

  TableRow _tableRow(BuildContext context, PlacesProvider p, Place place) {
    return TableRow(
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.border, width: 0.5)),
      ),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              if (place.photos.isNotEmpty)
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: Image.network(place.photos.first,
                      width: 40, height: 40, fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _placeholderIcon()),
                )
              else
                _placeholderIcon(),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(place.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                        overflow: TextOverflow.ellipsis),
                    Text(place.type, style: const TextStyle(color: AppColors.textHint, fontSize: 11)),
                  ],
                ),
              ),
              if (place.isFeatured) StatusBadge.featured(small: true),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(place.city, style: const TextStyle(fontSize: 13), overflow: TextOverflow.ellipsis),
              Text(place.state, style: const TextStyle(color: AppColors.textSecondary, fontSize: 11)),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Text('RD\$${place.pricePerNight.toStringAsFixed(0)}',
              style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.success)),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              const Icon(Icons.star, size: 14, color: AppColors.warning),
              const SizedBox(width: 4),
              Text(place.rating.toStringAsFixed(1)),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: place.isActive ? StatusBadge.active() : StatusBadge.inactive(),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.edit_outlined, size: 18),
                onPressed: () => context.go('${AppRoutes.placeEdit}/${place.id}'),
                tooltip: 'Editar',
                color: AppColors.textSecondary,
              ),
              IconButton(
                icon: Icon(
                  place.isActive ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                  size: 18,
                ),
                onPressed: () => p.setActive(place.id, !place.isActive),
                tooltip: place.isActive ? 'Desactivar' : 'Activar',
                color: AppColors.textSecondary,
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline, size: 18),
                color: AppColors.error,
                tooltip: 'Eliminar',
                onPressed: () async {
                  final ok = await ConfirmDialog.show(
                    context,
                    title: 'Eliminar lugar',
                    message: '¿Eliminar "${place.name}"? Esta acción no se puede deshacer.',
                  );
                  if (ok && context.mounted) p.delete(place.id);
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _placeholderIcon() {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: const Icon(Icons.cabin_rounded, color: AppColors.primary, size: 20),
    );
  }
}
