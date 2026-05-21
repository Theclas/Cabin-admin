import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../widgets/common/page_header.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _maintenanceMode = false;
  bool _allowNewRegistrations = true;
  bool _requireEmailVerification = false;
  final _supportEmailCtrl = TextEditingController(text: 'soporte@cabin.mx');
  final _appVersionCtrl = TextEditingController(text: '1.0.0');

  @override
  void dispose() {
    _supportEmailCtrl.dispose();
    _appVersionCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const PageHeader(title: 'Configuración', subtitle: 'Ajustes generales de la plataforma'),
          const SizedBox(height: 24),
          _section('General', [
            _settingRow(
              icon: Icons.build_outlined,
              title: 'Modo mantenimiento',
              subtitle: 'Deshabilita el acceso a la app temporalmente',
              trailing: Switch(
                value: _maintenanceMode,
                onChanged: (v) => setState(() => _maintenanceMode = v),
                activeThumbColor: AppColors.warning,
              ),
            ),
            const Divider(color: AppColors.border),
            _settingRow(
              icon: Icons.person_add_outlined,
              title: 'Permitir nuevos registros',
              subtitle: 'Los usuarios pueden crear cuentas nuevas',
              trailing: Switch(
                value: _allowNewRegistrations,
                onChanged: (v) => setState(() => _allowNewRegistrations = v),
                activeThumbColor: AppColors.success,
              ),
            ),
            const Divider(color: AppColors.border),
            _settingRow(
              icon: Icons.mark_email_read_outlined,
              title: 'Verificación de email requerida',
              subtitle: 'Los usuarios deben verificar su email para acceder',
              trailing: Switch(
                value: _requireEmailVerification,
                onChanged: (v) => setState(() => _requireEmailVerification = v),
                activeThumbColor: AppColors.primary,
              ),
            ),
          ]),
          const SizedBox(height: 16),
          _section('Contacto y versión', [
            Padding(
              padding: const EdgeInsets.all(4),
              child: TextField(
                controller: _supportEmailCtrl,
                decoration: const InputDecoration(
                  labelText: 'Email de soporte',
                  prefixIcon: Icon(Icons.email_outlined),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.all(4),
              child: TextField(
                controller: _appVersionCtrl,
                decoration: const InputDecoration(
                  labelText: 'Versión de la app',
                  prefixIcon: Icon(Icons.info_outlined),
                ),
              ),
            ),
          ]),
          const SizedBox(height: 16),
          _section('Información del sistema', [
            _infoRow('Firebase Project', 'cabin-de0c9'),
            _infoRow('Región', 'us-central1'),
            _infoRow('Plan', 'Blaze'),
            _infoRow('Admin Panel v', '1.0.0'),
          ]),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Configuración guardada'),
                  backgroundColor: AppColors.success,
                ),
              );
            },
            child: const Text('Guardar cambios'),
          ),
        ],
      ),
    );
  }

  Widget _section(String title, List<Widget> children) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: AppColors.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _settingRow({
    required IconData icon,
    required String title,
    required String subtitle,
    required Widget trailing,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
                Text(subtitle, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
              ],
            ),
          ),
          trailing,
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
          const Spacer(),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
        ],
      ),
    );
  }
}
