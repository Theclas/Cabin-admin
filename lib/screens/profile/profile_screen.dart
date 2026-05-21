import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../theme/app_colors.dart';
import '../../widgets/common/page_header.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const PageHeader(title: 'Mi perfil', subtitle: 'Información de tu cuenta'),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: AppColors.cardDecoration,
            child: Row(
              children: [
                CircleAvatar(
                  radius: 48,
                  backgroundColor: AppColors.primary.withValues(alpha: 0.2),
                  backgroundImage: auth.user?.photoURL != null
                      ? NetworkImage(auth.user!.photoURL!)
                      : null,
                  child: auth.user?.photoURL == null
                      ? Text(
                          auth.displayName.isNotEmpty ? auth.displayName[0].toUpperCase() : 'A',
                          style: const TextStyle(
                            fontSize: 36, color: AppColors.primary, fontWeight: FontWeight.bold),
                        )
                      : null,
                ),
                const SizedBox(width: 24),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(auth.displayName,
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(auth.email,
                        style: const TextStyle(color: AppColors.textSecondary, fontSize: 14)),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                      ),
                      child: Text(auth.role,
                          style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: AppColors.cardDecoration,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Información de cuenta', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                const SizedBox(height: 16),
                _infoRow('UID', auth.user?.uid ?? ''),
                const Divider(color: AppColors.border, height: 20),
                _infoRow('Email', auth.email),
                const Divider(color: AppColors.border, height: 20),
                _infoRow('Rol', auth.role),
                const Divider(color: AppColors.border, height: 20),
                _infoRow('Estado', auth.userData?['isActive'] == true ? 'Activo' : 'Inactivo'),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: AppColors.cardDecoration,
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text('Cerrar sesión', style: TextStyle(fontWeight: FontWeight.bold)),
                      Text('Salir del panel de administración',
                          style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                    ],
                  ),
                ),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
                  icon: const Icon(Icons.logout_rounded, size: 18),
                  label: const Text('Cerrar sesión'),
                  onPressed: () => context.read<AuthProvider>().signOut(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Row(
      children: [
        SizedBox(
          width: 100,
          child: Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(value,
              style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
              overflow: TextOverflow.ellipsis),
        ),
      ],
    );
  }
}
