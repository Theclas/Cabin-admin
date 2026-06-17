import 'dart:typed_data';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../config/app_config.dart';
import '../../config/routes.dart';
import '../../models/popup_ad.dart';
import '../../services/popup_ads_service.dart';
import '../../theme/app_colors.dart';
import '../../widgets/common/page_header.dart';

class PopupAdFormScreen extends StatefulWidget {
  final String? popupId;
  const PopupAdFormScreen({super.key, this.popupId});

  bool get isEditing => popupId != null;

  @override
  State<PopupAdFormScreen> createState() => _PopupAdFormScreenState();
}

class _PopupAdFormScreenState extends State<PopupAdFormScreen> {
  final _service = PopupAdsService();
  final _formKey = GlobalKey<FormState>();

  final _titleCtrl = TextEditingController();
  final _urlCtrl = TextEditingController();
  final _placeSearchCtrl = TextEditingController();

  PopupActionType _actionType = PopupActionType.none;
  String? _actionValue;
  String? _actionLabel;
  bool _active = true;
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now().add(const Duration(days: 7));
  int _maxDisplays = 3;
  double _displayDelay = 2;
  double _minCloseTime = 0;
  int _priority = 5;
  bool _dismissible = true;
  bool _showCloseButton = true;

  final _screens = <String, bool>{
    'home': true,
    'search': false,
    'favorites': false,
    'detail': false,
  };

  String _currentImageUrl = '';
  Uint8List? _pendingImageBytes;
  bool _imageLoading = false;

  List<Map<String, String>> _placeResults = [];
  bool _searchingPlaces = false;

  bool _loading = false;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    if (widget.isEditing) _loadExisting();
  }

  Future<void> _loadExisting() async {
    setState(() => _loading = true);
    final popup = await _service.getById(widget.popupId!);
    if (popup == null || !mounted) {
      setState(() => _loading = false);
      return;
    }
    setState(() {
      _titleCtrl.text = popup.title;
      _actionType = popup.actionType;
      _actionValue = popup.actionValue;
      _actionLabel = popup.actionLabel;
      _active = popup.active;
      _startDate = popup.startDate;
      _endDate = popup.endDate;
      _maxDisplays = popup.maxDisplaysPerUser;
      _displayDelay = popup.displayDelaySeconds.toDouble();
      _minCloseTime = popup.minTimeBeforeClose.toDouble();
      _priority = popup.priority;
      _dismissible = popup.dismissible;
      _showCloseButton = popup.showCloseButton;
      _currentImageUrl = popup.imageUrl;
      for (final s in popup.showOnScreens) {
        if (_screens.containsKey(s)) _screens[s] = true;
      }
      if (_actionType == PopupActionType.url) {
        _urlCtrl.text = _actionValue ?? '';
      } else if (_actionType == PopupActionType.place ||
          _actionType == PopupActionType.promotion) {
        _placeSearchCtrl.text = _actionLabel ?? '';
      }
      _loading = false;
    });
  }

  Future<void> _pickImage() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        withData: true,
        allowMultiple: false,
      );
      if (result == null || result.files.isEmpty) return;
      final bytes = result.files.first.bytes;
      if (bytes == null) return;
      if (bytes.lengthInBytes > 2 * 1024 * 1024) {
        _showError('La imagen supera los 2 MB. Elige una más pequeña.');
        return;
      }
      setState(() => _pendingImageBytes = bytes);
    } catch (_) {
      _showError('Error al seleccionar la imagen.');
    }
  }

  Future<void> _searchPlaces(String query) async {
    final q = query.trim();
    if (q.length < 2) {
      setState(() => _placeResults = []);
      return;
    }
    setState(() => _searchingPlaces = true);
    try {
      final snap = await FirebaseFirestore.instance
          .collection(AppConfig.colPlaces)
          .where('active', isEqualTo: true)
          .limit(100)
          .get();
      final lower = q.toLowerCase();
      if (mounted) {
        setState(() {
          _placeResults = snap.docs
              .where((d) =>
                  (d['name'] as String? ?? '').toLowerCase().contains(lower))
              .map((d) => {'id': d.id, 'name': d['name'] as String? ?? d.id})
              .take(8)
              .toList();
          _searchingPlaces = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _searchingPlaces = false);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_currentImageUrl.isEmpty && _pendingImageBytes == null) {
      _showError('Debes seleccionar una imagen para el popup.');
      return;
    }
    final selectedScreens =
        _screens.entries.where((e) => e.value).map((e) => e.key).toList();
    if (selectedScreens.isEmpty) {
      _showError('Selecciona al menos una pantalla donde mostrar el popup.');
      return;
    }
    if (_endDate.isBefore(_startDate)) {
      _showError('La fecha de fin debe ser posterior a la fecha de inicio.');
      return;
    }
    if (_actionType == PopupActionType.url &&
        (_urlCtrl.text.trim().isEmpty ||
            Uri.tryParse(_urlCtrl.text.trim()) == null)) {
      _showError('Ingresa una URL válida.');
      return;
    }

    setState(() => _saving = true);

    try {
      String imageUrl = _currentImageUrl;
      if (_pendingImageBytes != null) {
        setState(() => _imageLoading = true);
        imageUrl = await _service.uploadImage(
          _pendingImageBytes!,
          oldUrl: widget.isEditing ? _currentImageUrl : null,
        );
        if (mounted) setState(() => _imageLoading = false);
      }

      final data = <String, dynamic>{
        'title': _titleCtrl.text.trim(),
        'imageUrl': imageUrl,
        'actionType': _actionType.name,
        'actionValue': _actionType == PopupActionType.url
            ? _urlCtrl.text.trim()
            : _actionValue,
        'actionLabel': _actionLabel,
        'active': _active,
        'startDate': Timestamp.fromDate(_startDate),
        'endDate': Timestamp.fromDate(_endDate),
        'maxDisplaysPerUser': _maxDisplays,
        'displayDelaySeconds': _displayDelay.round(),
        'minTimeBeforeClose': _minCloseTime.round(),
        'showOnScreens': selectedScreens,
        'priority': _priority,
        'dismissible': _dismissible,
        'showCloseButton': _showCloseButton,
      };

      if (widget.isEditing) {
        await _service.update(widget.popupId!, data);
      } else {
        await _service.create(data);
      }

      if (mounted) context.go(AppRoutes.popupAds);
    } catch (e) {
      _showError('Error al guardar: $e');
    }

    if (mounted) setState(() => _saving = false);
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: AppColors.error),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PageHeader(
            title: widget.isEditing ? 'Editar Popup' : 'Nuevo Popup',
            subtitle: widget.isEditing
                ? 'Modifica el anuncio popup'
                : 'Configura un nuevo anuncio popup',
            actions: [
              OutlinedButton(
                onPressed: () => context.go(AppRoutes.popupAds),
                child: const Text('Cancelar'),
              ),
              const SizedBox(width: 12),
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
                label: Text(widget.isEditing ? 'Actualizar' : 'Crear'),
              ),
            ],
          ),
          const SizedBox(height: 24),
          if (_loading)
            const Center(child: CircularProgressIndicator())
          else
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 3, child: _buildForm()),
                  const SizedBox(width: 24),
                  SizedBox(width: 260, child: _buildPreview()),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _section('General', [
              _label('Título (interno, no visible para el usuario)'),
              TextFormField(
                controller: _titleCtrl,
                decoration: const InputDecoration(
                  hintText: 'Ej: Promo verano 2025',
                  prefixIcon: Icon(Icons.label_outline, size: 18),
                ),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Campo requerido' : null,
              ),
            ]),
            const SizedBox(height: 16),
            _section('Imagen', [
              const Text(
                'Tamaño sugerido: 1080×1350 px · Máximo 2 MB',
                style: TextStyle(color: AppColors.textHint, fontSize: 12),
              ),
              const SizedBox(height: 10),
              GestureDetector(
                onTap: _pickImage,
                child: DragTarget<Object>(
                  onAcceptWithDetails: (_) {},
                  builder: (_, __, ___) => Container(
                    height: 120,
                    decoration: BoxDecoration(
                      color: AppColors.hover,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Center(
                      child: _pendingImageBytes != null
                          ? const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.check_circle,
                                    color: AppColors.success, size: 20),
                                SizedBox(width: 8),
                                Text('Imagen seleccionada',
                                    style: TextStyle(
                                        color: AppColors.success, fontSize: 13)),
                              ],
                            )
                          : Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.cloud_upload_outlined,
                                    color: AppColors.textHint, size: 32),
                                const SizedBox(height: 8),
                                const Text(
                                  'Haz clic para seleccionar imagen',
                                  style: TextStyle(
                                      color: AppColors.textSecondary,
                                      fontSize: 13),
                                ),
                                if (_currentImageUrl.isNotEmpty)
                                  Text(
                                    'Imagen actual cargada',
                                    style: TextStyle(
                                        color: AppColors.primary
                                            .withValues(alpha: 0.8),
                                        fontSize: 11),
                                  ),
                              ],
                            ),
                    ),
                  ),
                ),
              ),
            ]),
            const SizedBox(height: 16),
            _section('Acción al tocar', [
              DropdownButtonFormField<PopupActionType>(
                value: _actionType,
                dropdownColor: AppColors.card,
                items: const [
                  DropdownMenuItem(
                      value: PopupActionType.none,
                      child: Text('Sin acción (solo informativo)')),
                  DropdownMenuItem(
                      value: PopupActionType.url,
                      child: Text('Abrir URL externa')),
                  DropdownMenuItem(
                      value: PopupActionType.place,
                      child: Text('Ir a un lugar')),
                  DropdownMenuItem(
                      value: PopupActionType.promotion,
                      child: Text('Ir a una promoción')),
                ],
                onChanged: (v) => setState(() {
                  _actionType = v!;
                  _actionValue = null;
                  _actionLabel = null;
                  _urlCtrl.clear();
                  _placeSearchCtrl.clear();
                  _placeResults = [];
                }),
              ),
              if (_actionType == PopupActionType.url) ...[
                const SizedBox(height: 12),
                TextFormField(
                  controller: _urlCtrl,
                  decoration: const InputDecoration(
                    labelText: 'URL',
                    hintText: 'https://...',
                    prefixIcon: Icon(Icons.link, size: 18),
                  ),
                  validator: (v) {
                    if (_actionType != PopupActionType.url) return null;
                    if (v == null || v.trim().isEmpty) return 'Ingresa una URL';
                    if (Uri.tryParse(v.trim()) == null) return 'URL inválida';
                    return null;
                  },
                ),
              ],
              if (_actionType == PopupActionType.place ||
                  _actionType == PopupActionType.promotion) ...[
                const SizedBox(height: 12),
                TextFormField(
                  controller: _placeSearchCtrl,
                  decoration: InputDecoration(
                    labelText: _actionType == PopupActionType.place
                        ? 'Buscar lugar por nombre'
                        : 'Buscar promoción por nombre',
                    prefixIcon: const Icon(Icons.search, size: 18),
                    suffixIcon: _searchingPlaces
                        ? const Padding(
                            padding: EdgeInsets.all(12),
                            child: SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          )
                        : null,
                  ),
                  onChanged: _searchPlaces,
                ),
                if (_actionLabel != null && _actionValue != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Row(
                      children: [
                        const Icon(Icons.check_circle,
                            color: AppColors.success, size: 16),
                        const SizedBox(width: 6),
                        Text(
                          'Seleccionado: $_actionLabel',
                          style: const TextStyle(
                              color: AppColors.success, fontSize: 12),
                        ),
                        const SizedBox(width: 8),
                        InkWell(
                          onTap: () => setState(() {
                            _actionValue = null;
                            _actionLabel = null;
                            _placeSearchCtrl.clear();
                            _placeResults = [];
                          }),
                          child: const Icon(Icons.close,
                              size: 16, color: AppColors.textHint),
                        ),
                      ],
                    ),
                  ),
                if (_placeResults.isNotEmpty)
                  Container(
                    margin: const EdgeInsets.only(top: 4),
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      children: _placeResults
                          .map((p) => ListTile(
                                dense: true,
                                title: Text(p['name']!,
                                    style: const TextStyle(fontSize: 13)),
                                subtitle: Text(p['id']!,
                                    style: const TextStyle(
                                        fontSize: 10,
                                        color: AppColors.textHint)),
                                onTap: () => setState(() {
                                  _actionValue = p['id'];
                                  _actionLabel = p['name'];
                                  _placeSearchCtrl.text = p['name']!;
                                  _placeResults = [];
                                }),
                              ))
                          .toList(),
                    ),
                  ),
              ],
            ]),
            const SizedBox(height: 16),
            _section('Pantallas donde mostrar', [
              ..._screens.keys.map((screen) => CheckboxListTile(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    value: _screens[screen],
                    activeColor: AppColors.primary,
                    title: Text(_screenLabel(screen),
                        style: const TextStyle(fontSize: 13)),
                    onChanged: (v) =>
                        setState(() => _screens[screen] = v ?? false),
                  )),
            ]),
            const SizedBox(height: 16),
            _section('Fechas', [
              Row(
                children: [
                  Expanded(
                    child: _datePicker(
                      label: 'Inicio',
                      value: _startDate,
                      onPick: (d) => setState(() => _startDate = d),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _datePicker(
                      label: 'Fin',
                      value: _endDate,
                      onPick: (d) => setState(() => _endDate = d),
                    ),
                  ),
                ],
              ),
            ]),
            const SizedBox(height: 16),
            _section('Comportamiento', [
              _label('Máximo de veces por usuario: $_maxDisplays'),
              Slider(
                value: _maxDisplays.toDouble(),
                min: 1,
                max: 10,
                divisions: 9,
                activeColor: AppColors.primary,
                onChanged: (v) => setState(() => _maxDisplays = v.round()),
              ),
              _label('Retraso antes de aparecer: ${_displayDelay.round()} s'),
              Slider(
                value: _displayDelay,
                min: 0,
                max: 30,
                divisions: 30,
                activeColor: AppColors.primary,
                onChanged: (v) => setState(() => _displayDelay = v),
              ),
              _label(
                  'Tiempo mínimo antes de cerrar: ${_minCloseTime.round()} s'),
              Slider(
                value: _minCloseTime,
                min: 0,
                max: 10,
                divisions: 10,
                activeColor: AppColors.primary,
                onChanged: (v) => setState(() => _minCloseTime = v),
              ),
              _label('Prioridad: $_priority'),
              Slider(
                value: _priority.toDouble(),
                min: 1,
                max: 10,
                divisions: 9,
                activeColor: AppColors.primary,
                onChanged: (v) => setState(() => _priority = v.round()),
              ),
              SwitchListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                title: const Text('Cerrar al tocar fuera',
                    style: TextStyle(fontSize: 13)),
                value: _dismissible,
                activeColor: AppColors.primary,
                onChanged: (v) => setState(() => _dismissible = v),
              ),
              SwitchListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                title: const Text('Mostrar botón X',
                    style: TextStyle(fontSize: 13)),
                subtitle: const Text('Recomendado siempre activado',
                    style:
                        TextStyle(fontSize: 11, color: AppColors.textHint)),
                value: _showCloseButton,
                activeColor: AppColors.primary,
                onChanged: (v) => setState(() => _showCloseButton = v),
              ),
              SwitchListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                title: const Text('Activo', style: TextStyle(fontSize: 13)),
                value: _active,
                activeColor: AppColors.primary,
                onChanged: (v) => setState(() => _active = v),
              ),
            ]),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildPreview() {
    return Column(
      children: [
        const Text(
          'Vista previa',
          style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: AppColors.textPrimary),
        ),
        const SizedBox(height: 12),
        Container(
          width: 240,
          height: 480,
          decoration: BoxDecoration(
            color: Colors.black87,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.border, width: 2),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: Stack(
              children: [
                Container(color: const Color(0xFF0A0A14)),
                Container(color: Colors.black.withValues(alpha: 0.7)),
                Center(
                  child: Container(
                    width: 200,
                    decoration: BoxDecoration(
                      color: const Color(0xFF16162A),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Stack(
                        children: [
                          _pendingImageBytes != null
                              ? Image.memory(
                                  _pendingImageBytes!,
                                  width: 200,
                                  fit: BoxFit.fitWidth,
                                )
                              : _currentImageUrl.isNotEmpty
                                  ? CachedNetworkImage(
                                      imageUrl: _currentImageUrl,
                                      width: 200,
                                      fit: BoxFit.fitWidth,
                                    )
                                  : Container(
                                      width: 200,
                                      height: 250,
                                      color: const Color(0xFF1E1E35),
                                      child: const Center(
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(Icons.image_outlined,
                                                color: Color(0xFF6B6B8A),
                                                size: 36),
                                            SizedBox(height: 8),
                                            Text(
                                              'Imagen del popup',
                                              style: TextStyle(
                                                  color: Color(0xFF6B6B8A),
                                                  fontSize: 11),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                          if (_showCloseButton)
                            Positioned(
                              top: 6,
                              right: 6,
                              child: Container(
                                width: 24,
                                height: 24,
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.6),
                                  shape: BoxShape.circle,
                                ),
                                child: _minCloseTime > 0
                                    ? Center(
                                        child: Text(
                                          '${_minCloseTime.round()}',
                                          style: const TextStyle(
                                              color: Colors.white70,
                                              fontSize: 9,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      )
                                    : const Icon(Icons.close,
                                        color: Colors.white, size: 14),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: AppColors.cardDecoration,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _previewRow('Retraso', '${_displayDelay.round()} seg'),
              _previewRow('Cierre mín.', '${_minCloseTime.round()} seg'),
              _previewRow('Prioridad', '$_priority'),
              _previewRow('Max/usuario', '$_maxDisplays veces'),
              _previewRow('Acción', _actionType.name),
            ],
          ),
        ),
      ],
    );
  }

  Widget _previewRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style:
                  const TextStyle(color: AppColors.textHint, fontSize: 11)),
          Text(value,
              style: const TextStyle(
                  color: AppColors.textSecondary, fontSize: 11)),
        ],
      ),
    );
  }

  Widget _section(String title, List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppColors.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: AppColors.textPrimary)),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _label(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: Text(text,
            style: const TextStyle(
                color: AppColors.textSecondary, fontSize: 12)),
      );

  Widget _datePicker({
    required String label,
    required DateTime value,
    required ValueChanged<DateTime> onPick,
  }) {
    final fmt = DateFormat('dd/MM/yyyy HH:mm');
    return InkWell(
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: value,
          firstDate: DateTime(2024),
          lastDate: DateTime(2030),
        );
        if (date == null || !mounted) return;
        final time = await showTimePicker(
          context: context,
          initialTime: TimeOfDay.fromDateTime(value),
        );
        if (time == null) return;
        onPick(DateTime(
            date.year, date.month, date.day, time.hour, time.minute));
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.hover,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today_outlined,
                size: 16, color: AppColors.textHint),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: const TextStyle(
                          color: AppColors.textHint, fontSize: 10)),
                  Text(fmt.format(value),
                      style: const TextStyle(
                          color: AppColors.textPrimary, fontSize: 12)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _screenLabel(String screen) => switch (screen) {
        'home' => 'Explorar / Mapa',
        'search' => 'Búsqueda',
        'favorites' => 'Favoritos',
        'detail' => 'Detalle de lugar',
        _ => screen,
      };

  @override
  void dispose() {
    _titleCtrl.dispose();
    _urlCtrl.dispose();
    _placeSearchCtrl.dispose();
    super.dispose();
  }
}
