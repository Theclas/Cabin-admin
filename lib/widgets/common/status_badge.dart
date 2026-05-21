import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

class StatusBadge extends StatelessWidget {
  final String label;
  final Color color;
  final bool small;

  const StatusBadge({
    super.key,
    required this.label,
    required this.color,
    this.small = false,
  });

  factory StatusBadge.active({bool small = false}) =>
      StatusBadge(label: 'Activo', color: AppColors.success, small: small);

  factory StatusBadge.inactive({bool small = false}) =>
      StatusBadge(label: 'Inactivo', color: AppColors.textHint, small: small);

  factory StatusBadge.pending({bool small = false}) =>
      StatusBadge(label: 'Pendiente', color: AppColors.warning, small: small);

  factory StatusBadge.banned({bool small = false}) =>
      StatusBadge(label: 'Baneado', color: AppColors.error, small: small);

  factory StatusBadge.featured({bool small = false}) =>
      StatusBadge(label: 'Destacado', color: AppColors.accent, small: small);

  @override
  Widget build(BuildContext context) {
    final fs = small ? 10.0 : 12.0;
    final px = small ? 6.0 : 10.0;
    final py = small ? 2.0 : 4.0;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: px, vertical: py),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 5),
          Text(label, style: TextStyle(color: color, fontSize: fs, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
