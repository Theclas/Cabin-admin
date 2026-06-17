import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../config/app_config.dart';
import '../../theme/app_colors.dart';
import '../../widgets/common/page_header.dart';

class AdsScreen extends StatefulWidget {
  const AdsScreen({super.key});

  @override
  State<AdsScreen> createState() => _AdsScreenState();
}

class _AdsScreenState extends State<AdsScreen> {
  final _androidCtrl = TextEditingController();
  final _iosCtrl = TextEditingController();

  bool _enabled = true;
  bool _bannerEnabled = true;
  bool _testMode = false;
  bool _loading = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection(AppConfig.colAds)
          .doc('admob')
          .get();
      if (doc.exists && doc.data() != null) {
        final d = doc.data()!;
        setState(() {
          _enabled = d['enabled'] as bool? ?? true;
          _bannerEnabled = d['bannerEnabled'] as bool? ?? true;
          _testMode = d['testMode'] as bool? ?? false;
          _androidCtrl.text = d['androidAdUnitId'] as String? ?? '';
          _iosCtrl.text = d['iosAdUnitId'] as String? ?? '';
        });
      }
    } catch (_) {}
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      await FirebaseFirestore.instance
          .collection(AppConfig.colAds)
          .doc('admob')
          .set({
        'enabled': _enabled,
        'bannerEnabled': _bannerEnabled,
        'androidAdUnitId': _androidCtrl.text.trim(),
        'iosAdUnitId': _iosCtrl.text.trim(),
        'testMode': _testMode,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Configuración guardada'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al guardar: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
    if (mounted) setState(() => _saving = false);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PageHeader(
            title: 'AdMob — Configuración',
            subtitle: 'Banner inferior discreto en la app móvil',
            actions: [
              FilledButton.icon(
                onPressed: _saving ? null : _save,
                icon: _saving
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.save_rounded, size: 18),
                label: const Text('Guardar'),
              ),
            ],
          ),
          const SizedBox(height: 24),
          if (_loading)
            const Center(child: CircularProgressIndicator())
          else
            Expanded(child: _buildContent()),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoBanner(),
          const SizedBox(height: 24),
          _buildMasterSwitch(),
          const SizedBox(height: 16),
          _buildBannerSection(),
          const SizedBox(height: 16),
          _buildComingSoon(),
        ],
      ),
    );
  }

  Widget _buildInfoBanner() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.success.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.success.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.check_circle_outline,
              color: AppColors.success, size: 20),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Solo el banner inferior está activo. '
              'Para no saturar la experiencia, no se usan intersticiales ni anuncios nativos.',
              style:
                  TextStyle(color: AppColors.success, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMasterSwitch() {
    return _card(
      child: Row(
        children: [
          const Icon(Icons.power_settings_new_rounded,
              color: AppColors.primary, size: 22),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Anuncios habilitados',
                    style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary)),
                Text('Interruptor maestro — desactiva todos los anuncios',
                    style: TextStyle(
                        color: AppColors.textSecondary, fontSize: 12)),
              ],
            ),
          ),
          Switch(
            value: _enabled,
            onChanged: (v) => setState(() => _enabled = v),
            activeColor: AppColors.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildBannerSection() {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.view_stream_rounded,
                  color: AppColors.info, size: 20),
              const SizedBox(width: 10),
              const Text('Banner inferior',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: AppColors.textPrimary)),
              const Spacer(),
              Switch(
                value: _bannerEnabled,
                onChanged: _enabled
                    ? (v) => setState(() => _bannerEnabled = v)
                    : null,
                activeColor: AppColors.primary,
              ),
            ],
          ),
          const Divider(color: AppColors.border, height: 24),
          _field(
            controller: _androidCtrl,
            label: 'AdUnit ID — Android',
            hint: 'ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX',
            icon: Icons.android_rounded,
            enabled: _enabled && _bannerEnabled,
          ),
          const SizedBox(height: 12),
          _field(
            controller: _iosCtrl,
            label: 'AdUnit ID — iOS',
            hint: 'ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX',
            icon: Icons.apple_rounded,
            enabled: _enabled && _bannerEnabled,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Checkbox(
                value: _testMode,
                onChanged: (v) => setState(() => _testMode = v ?? false),
                activeColor: AppColors.warning,
              ),
              const SizedBox(width: 8),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Modo prueba',
                      style: TextStyle(
                          color: AppColors.textPrimary, fontSize: 13)),
                  Text(
                    'Usa IDs de test de Google — actívalo en desarrollo',
                    style: TextStyle(
                        color: AppColors.textHint, fontSize: 11),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildComingSoon() {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.upcoming_rounded,
                  color: AppColors.textHint, size: 20),
              const SizedBox(width: 10),
              const Text('Próximamente',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: AppColors.textHint)),
            ],
          ),
          const SizedBox(height: 12),
          _comingSoonItem('Intersticiales'),
          _comingSoonItem('Anuncios nativos'),
          _comingSoonItem('Recompensados'),
        ],
      ),
    );
  }

  Widget _comingSoonItem(String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          const Icon(Icons.lock_outline_rounded,
              size: 14, color: AppColors.textHint),
          const SizedBox(width: 8),
          Text(label,
              style: const TextStyle(
                  color: AppColors.textHint, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _field({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    required bool enabled,
  }) {
    return TextField(
      controller: controller,
      enabled: enabled,
      style: const TextStyle(
          color: AppColors.textPrimary, fontFamily: 'monospace', fontSize: 13),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, size: 18, color: AppColors.textHint),
        hintStyle:
            const TextStyle(color: AppColors.textHint, fontSize: 12),
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

  @override
  void dispose() {
    _androidCtrl.dispose();
    _iosCtrl.dispose();
    super.dispose();
  }
}
