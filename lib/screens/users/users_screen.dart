import 'package:flutter/material.dart';
import '../../services/users_service.dart';
import '../../models/app_user.dart';
import '../../theme/app_colors.dart';
import '../../widgets/common/page_header.dart';
import '../../widgets/common/status_badge.dart';
import '../../widgets/common/empty_state.dart';
import '../../widgets/common/confirm_dialog.dart';
import '../../config/app_config.dart';

class UsersScreen extends StatefulWidget {
  const UsersScreen({super.key});

  @override
  State<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
  final _service = UsersService();
  List<AppUser> _users = [];
  List<AppUser> _filtered = [];
  bool _loading = true;
  String _search = '';
  String _roleFilter = '';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    _users = await _service.getAll();
    _applyFilter();
    setState(() => _loading = false);
  }

  void _applyFilter() {
    _filtered = _users.where((u) {
      final matchSearch = _search.isEmpty ||
          u.displayName.toLowerCase().contains(_search.toLowerCase()) ||
          u.email.toLowerCase().contains(_search.toLowerCase());
      final matchRole = _roleFilter.isEmpty || u.role == _roleFilter;
      return matchSearch && matchRole;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PageHeader(title: 'Usuarios', subtitle: '${_filtered.length} usuarios'),
          const SizedBox(height: 20),
          _buildFilters(),
          const SizedBox(height: 16),
          Expanded(child: _buildContent()),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            onChanged: (v) { _search = v; _applyFilter(); setState(() {}); },
            decoration: const InputDecoration(
              hintText: 'Buscar por nombre o email...',
              prefixIcon: Icon(Icons.search, size: 18),
              isDense: true,
              contentPadding: EdgeInsets.symmetric(vertical: 10),
            ),
          ),
        ),
        const SizedBox(width: 12),
        DropdownButton<String>(
          value: _roleFilter.isEmpty ? null : _roleFilter,
          hint: const Text('Rol', style: TextStyle(color: AppColors.textHint)),
          dropdownColor: AppColors.card,
          underline: const SizedBox(),
          items: const [
            DropdownMenuItem(value: '', child: Text('Todos los roles')),
            DropdownMenuItem(value: 'user', child: Text('Usuario')),
            DropdownMenuItem(value: 'moderator', child: Text('Moderador')),
            DropdownMenuItem(value: 'admin', child: Text('Admin')),
            DropdownMenuItem(value: 'superadmin', child: Text('Superadmin')),
          ],
          onChanged: (v) { _roleFilter = v ?? ''; _applyFilter(); setState(() {}); },
        ),
        const SizedBox(width: 8),
        IconButton(icon: const Icon(Icons.refresh), onPressed: _load, color: AppColors.textSecondary),
      ],
    );
  }

  Widget _buildContent() {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_filtered.isEmpty) return const EmptyState(icon: Icons.people_outline, title: 'No hay usuarios');

    return Container(
      decoration: AppColors.cardDecoration,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: SingleChildScrollView(
          child: Table(
            columnWidths: const {
              0: FlexColumnWidth(3),
              1: FlexColumnWidth(1.5),
              2: FlexColumnWidth(1),
              3: FlexColumnWidth(1),
              4: FlexColumnWidth(2),
            },
            children: [
              _header(),
              ..._filtered.map(_row),
            ],
          ),
        ),
      ),
    );
  }

  TableRow _header() => TableRow(
        decoration: const BoxDecoration(color: AppColors.hover),
        children: ['Usuario', 'Email', 'Rol', 'Estado', 'Acciones']
            .map((h) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Text(h, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
                ))
            .toList(),
      );

  TableRow _row(AppUser user) => TableRow(
        decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.border, width: 0.5))),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: AppColors.secondary.withValues(alpha: 0.2),
                  backgroundImage: user.photoUrl != null ? NetworkImage(user.photoUrl!) : null,
                  child: user.photoUrl == null
                      ? Text(user.displayName.isNotEmpty ? user.displayName[0].toUpperCase() : 'U',
                          style: const TextStyle(color: AppColors.secondary, fontWeight: FontWeight.bold, fontSize: 13))
                      : null,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(user.displayName, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                      overflow: TextOverflow.ellipsis),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Text(user.email, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                overflow: TextOverflow.ellipsis),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: _roleBadge(user.role),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: user.isBanned
                ? StatusBadge.banned()
                : user.isActive
                    ? StatusBadge.active()
                    : StatusBadge.inactive(),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _roleMenu(user),
                if (!user.isBanned)
                  IconButton(
                    icon: const Icon(Icons.block, size: 18, color: AppColors.error),
                    onPressed: () => _banUser(user),
                    tooltip: 'Banear',
                  )
                else
                  IconButton(
                    icon: const Icon(Icons.check_circle_outline, size: 18, color: AppColors.success),
                    onPressed: () => _unbanUser(user),
                    tooltip: 'Desbanear',
                  ),
              ],
            ),
          ),
        ],
      );

  Widget _roleBadge(String role) {
    final colors = {
      'superadmin': AppColors.secondary,
      'admin': AppColors.primary,
      'moderator': AppColors.accent,
      'user': AppColors.textSecondary,
    };
    return StatusBadge(label: role, color: colors[role] ?? AppColors.textHint);
  }

  Widget _roleMenu(AppUser user) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert, size: 18, color: AppColors.textSecondary),
      color: AppColors.card,
      itemBuilder: (_) => ['user', 'moderator', 'admin', 'superadmin']
              .map((r) => PopupMenuItem(
                    value: r,
                    child: Text('Cambiar a $r'),
                  ))
              .toList(),
      onSelected: (role) async {
        await _service.setRole(user.uid, role);
        _load();
      },
    );
  }

  Future<void> _banUser(AppUser user) async {
    final ctrl = TextEditingController();
    final reason = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.card,
        title: const Text('Banear usuario'),
        content: TextField(
          controller: ctrl,
          decoration: const InputDecoration(labelText: 'Motivo del ban'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () => Navigator.pop(ctx, ctrl.text),
            child: const Text('Banear'),
          ),
        ],
      ),
    );
    if (reason != null && reason.isNotEmpty) {
      await _service.ban(user.uid, reason);
      _load();
    }
  }

  Future<void> _unbanUser(AppUser user) async {
    final ok = await ConfirmDialog.show(
      context,
      title: 'Desbanear usuario',
      message: '¿Deseas restablecer el acceso a ${user.displayName}?',
      confirmLabel: 'Desbanear',
      confirmColor: AppColors.success,
    );
    if (ok) { await _service.unban(user.uid); _load(); }
  }
}
