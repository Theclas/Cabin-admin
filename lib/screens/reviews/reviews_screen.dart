import 'package:flutter/material.dart';
import '../../services/reviews_service.dart';
import '../../models/review.dart';
import '../../theme/app_colors.dart';
import '../../widgets/common/page_header.dart';
import '../../widgets/common/status_badge.dart';
import '../../widgets/common/empty_state.dart';
import '../../widgets/common/confirm_dialog.dart';

class ReviewsScreen extends StatefulWidget {
  const ReviewsScreen({super.key});

  @override
  State<ReviewsScreen> createState() => _ReviewsScreenState();
}

class _ReviewsScreenState extends State<ReviewsScreen> {
  final _service = ReviewsService();
  List<Review> _reviews = [];
  List<Review> _filtered = [];
  bool _loading = true;
  bool _showFlaggedOnly = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    _reviews = await _service.getAll();
    _applyFilter();
    setState(() => _loading = false);
  }

  void _applyFilter() {
    _filtered = _showFlaggedOnly ? _reviews.where((r) => r.isFlagged).toList() : _reviews;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PageHeader(
            title: 'Reseñas',
            subtitle: '${_filtered.length} reseñas',
            actions: [
              Row(
                children: [
                  const Text('Solo reportadas', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                  Switch(
                    value: _showFlaggedOnly,
                    onChanged: (v) { setState(() => _showFlaggedOnly = v); _applyFilter(); },
                    activeThumbColor: AppColors.warning,
                  ),
                  const SizedBox(width: 8),
                  IconButton(icon: const Icon(Icons.refresh), onPressed: _load, color: AppColors.textSecondary),
                ],
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
    if (_filtered.isEmpty) {
      return const EmptyState(icon: Icons.star_outline, title: 'No hay reseñas');
    }
    return ListView.separated(
      itemCount: _filtered.length,
      separatorBuilder: (_, __) => const Divider(color: AppColors.border, height: 1),
      itemBuilder: (_, i) => _reviewCard(_filtered[i]),
    );
  }

  Widget _reviewCard(Review review) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppColors.cardDecoration,
      margin: const EdgeInsets.only(bottom: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: AppColors.primary.withValues(alpha: 0.2),
            backgroundImage: review.userPhoto != null ? NetworkImage(review.userPhoto!) : null,
            child: review.userPhoto == null
                ? Text(review.userName.isNotEmpty ? review.userName[0].toUpperCase() : 'U',
                    style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold))
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(review.userName, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                    const SizedBox(width: 8),
                    ...List.generate(5, (i) => Icon(
                          i < review.rating ? Icons.star : Icons.star_border,
                          size: 14,
                          color: AppColors.warning,
                        )),
                    const SizedBox(width: 8),
                    Text(review.placeName,
                        style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                    const Spacer(),
                    if (review.isFlagged) const StatusBadge(label: 'Reportada', color: AppColors.warning),
                    const SizedBox(width: 8),
                    review.isVisible ? StatusBadge.active() : StatusBadge.inactive(),
                  ],
                ),
                const SizedBox(height: 6),
                Text(review.comment, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Column(
            children: [
              IconButton(
                icon: Icon(review.isVisible ? Icons.visibility_off_outlined : Icons.visibility_outlined, size: 18),
                onPressed: () async {
                  await _service.setVisible(review.id, !review.isVisible);
                  _load();
                },
                tooltip: review.isVisible ? 'Ocultar' : 'Mostrar',
                color: AppColors.textSecondary,
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline, size: 18),
                color: AppColors.error,
                onPressed: () async {
                  final ok = await ConfirmDialog.show(
                    context,
                    title: 'Eliminar reseña',
                    message: '¿Eliminar esta reseña? No se puede deshacer.',
                  );
                  if (ok && context.mounted) { await _service.delete(review.id); _load(); }
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
