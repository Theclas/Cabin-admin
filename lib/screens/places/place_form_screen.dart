import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../providers/places_provider.dart';
import '../../services/storage_service.dart';
import '../../services/places_service.dart';
import '../../theme/app_colors.dart';
import '../../config/app_config.dart';
import '../../config/routes.dart';

class PlaceFormScreen extends StatefulWidget {
  final String? placeId;
  const PlaceFormScreen({super.key, this.placeId});

  @override
  State<PlaceFormScreen> createState() => _PlaceFormScreenState();
}

class _PlaceFormScreenState extends State<PlaceFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _storage = StorageService();
  final _placesService = PlacesService();

  bool _loading = false;
  bool _loadingPlace = false;

  final _nameCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _whatsappCtrl = TextEditingController();
  final _latCtrl = TextEditingController();
  final _lngCtrl = TextEditingController();

  String _type = 'cabaña';
  String _city = '';
  String _province = '';

  // Centro de República Dominicana como coordenadas por defecto
  static const double _defaultLat = 18.7357;
  static const double _defaultLng = -70.1627;
  static const double _defaultZoom = 8.0;

  double _lat = _defaultLat;
  double _lng = _defaultLng;
  bool _isActive = true;
  bool _isFeatured = false;
  bool _is24h = false;
  List<String> _existingPhotos = [];
  List<Uint8List> _newPhotoBytes = [];
  final List<String> _amenities = [];
  final _mapController = MapController();

  bool get _isEdit => widget.placeId != null;

  static const _placeTypes = [
    'cabaña', 'motel', 'hotel', 'villa', 'bungalow', 'glamping', 'hostal', 'otro'
  ];

  @override
  void initState() {
    super.initState();
    _latCtrl.text = _lat.toStringAsFixed(6);
    _lngCtrl.text = _lng.toStringAsFixed(6);
    if (_isEdit) _loadPlace();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    _addressCtrl.dispose();
    _priceCtrl.dispose();
    _phoneCtrl.dispose();
    _whatsappCtrl.dispose();
    _latCtrl.dispose();
    _lngCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadPlace() async {
    setState(() => _loadingPlace = true);
    final place = await _placesService.getById(widget.placeId!);
    if (place != null && mounted) {
      setState(() {
        _nameCtrl.text = place.name;
        _descCtrl.text = place.description;
        _addressCtrl.text = place.address;
        _priceCtrl.text = place.pricePerNight.toStringAsFixed(0);
        _phoneCtrl.text = place.phone;
        _whatsappCtrl.text = place.whatsapp;
        _type = place.type;
        _city = place.city;
        _province = place.state;
        _lat = place.lat != 0 ? place.lat : _defaultLat;
        _lng = place.lng != 0 ? place.lng : _defaultLng;
        _latCtrl.text = _lat.toStringAsFixed(6);
        _lngCtrl.text = _lng.toStringAsFixed(6);
        _isActive = place.isActive;
        _isFeatured = place.isFeatured;
        _existingPhotos = List.from(place.photos);
        _amenities.addAll(place.amenities);
        _loadingPlace = false;
      });
      // Mover la cámara del mapa a la ubicación del lugar
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _mapController.move(LatLng(_lat, _lng), 14);
      });
    }
  }

  void _onMapTap(TapPosition _, LatLng latlng) {
    setState(() {
      _lat = latlng.latitude;
      _lng = latlng.longitude;
      _latCtrl.text = _lat.toStringAsFixed(6);
      _lngCtrl.text = _lng.toStringAsFixed(6);
    });
  }

  void _applyManualCoords() {
    final lat = double.tryParse(_latCtrl.text.trim());
    final lng = double.tryParse(_lngCtrl.text.trim());
    if (lat == null || lng == null) {
      _showError('Coordenadas inválidas. Usa formato: 18.486138');
      return;
    }
    // Validar que estén en los bounds de República Dominicana (con margen)
    if (lat < 17.0 || lat > 20.5 || lng < -72.5 || lng > -68.0) {
      _showError('Las coordenadas están fuera de los límites de República Dominicana.');
      return;
    }
    setState(() {
      _lat = lat;
      _lng = lng;
    });
    _mapController.move(LatLng(_lat, _lng), 14);
  }

  void _centerMap() {
    _mapController.move(LatLng(_lat, _lng), 14);
  }

  Future<void> _pickImages() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: true,
      withData: true,
    );
    if (result == null) return;
    setState(() {
      for (final f in result.files) {
        if (f.bytes != null &&
            _existingPhotos.length + _newPhotoBytes.length < AppConfig.maxPlacePhotos) {
          _newPhotoBytes.add(f.bytes!);
        }
      }
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_city.isEmpty || _province.isEmpty) {
      _showError('Selecciona ciudad y provincia');
      return;
    }
    // Verificar que se haya colocado un pin en el mapa (diferente al default)
    if (_lat == _defaultLat && _lng == _defaultLng && !_isEdit) {
      final continuar = await _confirmDefaultCoords();
      if (!continuar) return;
    }
    setState(() => _loading = true);
    try {
      final newUrls = await _storage.uploadMultiple(
          _newPhotoBytes, AppConfig.storagePlaces, 'jpg');
      final allPhotos = [..._existingPhotos, ...newUrls];

      final price = double.tryParse(_priceCtrl.text) ?? 0;
      final geo = GeoPoint(_lat, _lng);
      final data = {
        'name': _nameCtrl.text.trim(),
        'description': _descCtrl.text.trim(),
        'type': _type,
        'address': _addressCtrl.text.trim(),
        'city': _city,
        'state': _province,
        'phone': _phoneCtrl.text.trim(),
        'whatsapp': _whatsappCtrl.text.trim(),
        'geopoint': geo,
        'location': geo,
        'photos': allPhotos,
        'amenities': _amenities,
        'pricePerNight': price,
        'priceMin': price,
        'priceMax': price,
        'isActive': _isActive,
        'active': _isActive,
        'isFeatured': _isFeatured,
        'featured': _isFeatured,
        'is24h': _is24h,
        'extras': {},
      };

      final provider = context.read<PlacesProvider>();
      if (_isEdit) {
        await provider.update(widget.placeId!, data);
      } else {
        await provider.create(data);
      }

      if (mounted) context.go(AppRoutes.places);
    } catch (e) {
      if (mounted) _showError(e.toString());
      setState(() => _loading = false);
    }
  }

  Future<bool> _confirmDefaultCoords() async {
    return await showDialog<bool>(
          context: context,
          builder: (_) => AlertDialog(
            backgroundColor: AppColors.card,
            title: const Text('Ubicación no establecida'),
            content: const Text(
              'No has seleccionado una ubicación en el mapa.\n\n'
              'El lugar quedará ubicado en el centro de RD. '
              '¿Deseas continuar de todos modos?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Continuar'),
              ),
            ],
          ),
        ) ??
        false;
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: AppColors.error),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loadingPlace) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Encabezado
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => context.go(AppRoutes.places),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _isEdit ? 'Editar lugar' : 'Nuevo lugar',
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  if (_isEdit) ...[
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'ID: ${widget.placeId}',
                        style: const TextStyle(color: AppColors.primary, fontSize: 11),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 24),

              // Contenido principal en dos columnas
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 3, child: _buildMainForm()),
                  const SizedBox(width: 20),
                  Expanded(flex: 2, child: _buildSidePanel()),
                ],
              ),
              const SizedBox(height: 24),

              // Acciones
              Row(
                children: [
                  const Spacer(),
                  TextButton(
                    onPressed: () => context.go(AppRoutes.places),
                    child: const Text('Cancelar'),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    onPressed: _loading ? null : _submit,
                    icon: _loading
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2),
                          )
                        : Icon(_isEdit ? Icons.save_outlined : Icons.add),
                    label: Text(_isEdit ? 'Guardar cambios' : 'Crear lugar'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMainForm() {
    return Column(
      children: [
        // ── Información básica ──────────────────────────────────────
        _section('Información básica', [
          TextFormField(
            controller: _nameCtrl,
            decoration: const InputDecoration(
              labelText: 'Nombre del lugar',
              prefixIcon: Icon(Icons.store_outlined),
            ),
            validator: (v) => v == null || v.isEmpty ? 'Requerido' : null,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _type,
                  decoration: const InputDecoration(
                    labelText: 'Tipo de lugar',
                    prefixIcon: Icon(Icons.category_outlined),
                  ),
                  dropdownColor: AppColors.card,
                  items: _placeTypes
                      .map((t) => DropdownMenuItem(
                            value: t,
                            child: Text(
                              t[0].toUpperCase() + t.substring(1),
                            ),
                          ))
                      .toList(),
                  onChanged: (v) => setState(() => _type = v!),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  controller: _priceCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Precio por noche (DOP)',
                    prefixText: 'RD\$ ',
                    prefixIcon: Icon(Icons.attach_money),
                  ),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))],
                  validator: (v) => v == null || v.isEmpty ? 'Requerido' : null,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _descCtrl,
            decoration: const InputDecoration(
              labelText: 'Descripción',
              prefixIcon: Icon(Icons.description_outlined),
              alignLabelWithHint: true,
            ),
            maxLines: 4,
            validator: (v) => v == null || v.isEmpty ? 'Requerido' : null,
          ),
        ]),
        const SizedBox(height: 16),

        // ── Contacto ────────────────────────────────────────────────
        _section('Contacto', [
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _phoneCtrl,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: 'Teléfono',
                    hintText: '+1 809 000 0000',
                    prefixIcon: Icon(Icons.phone_outlined),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  controller: _whatsappCtrl,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: 'WhatsApp',
                    hintText: '+1 809 000 0000',
                    prefixIcon: Icon(Icons.chat_outlined),
                  ),
                ),
              ),
            ],
          ),
        ]),
        const SizedBox(height: 16),

        // ── Ubicación ───────────────────────────────────────────────
        _section('Ubicación', [
          TextFormField(
            controller: _addressCtrl,
            decoration: const InputDecoration(
              labelText: 'Dirección (Calle, Sector, Municipio)',
              prefixIcon: Icon(Icons.signpost_outlined),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  initialValue: _city,
                  decoration: const InputDecoration(
                    labelText: 'Ciudad / Municipio',
                    prefixIcon: Icon(Icons.location_city_outlined),
                  ),
                  onChanged: (v) => _city = v,
                  validator: (v) => v == null || v.isEmpty ? 'Requerido' : null,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _province.isEmpty ? null : _province,
                  decoration: const InputDecoration(
                    labelText: 'Provincia',
                    prefixIcon: Icon(Icons.map_outlined),
                  ),
                  dropdownColor: AppColors.card,
                  isExpanded: true,
                  items: AppConfig.dominicanaProvinces
                      .map((s) => DropdownMenuItem(
                            value: s,
                            child: Text(s, overflow: TextOverflow.ellipsis),
                          ))
                      .toList(),
                  onChanged: (v) => setState(() => _province = v ?? ''),
                  validator: (v) => v == null || v.isEmpty ? 'Requerido' : null,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Mapa interactivo
          _buildMapSection(),
        ]),
        const SizedBox(height: 16),

        // ── Amenidades ──────────────────────────────────────────────
        _section('Amenidades', [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: AppConfig.amenitiesList.map((a) {
              final selected = _amenities.contains(a);
              return FilterChip(
                label: Text(a),
                selected: selected,
                onSelected: (v) {
                  setState(() {
                    if (v) {
                      _amenities.add(a);
                    } else {
                      _amenities.remove(a);
                    }
                  });
                },
                selectedColor: AppColors.primary.withValues(alpha: 0.18),
                checkmarkColor: AppColors.primary,
                labelStyle: TextStyle(
                  color: selected ? AppColors.primary : AppColors.textSecondary,
                  fontSize: 12,
                ),
              );
            }).toList(),
          ),
        ]),
      ],
    );
  }

  Widget _buildMapSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Controles de coordenadas manuales
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.my_location, color: AppColors.primary, size: 16),
                  const SizedBox(width: 6),
                  const Text(
                    'Coordenadas GPS',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                      color: AppColors.primary,
                    ),
                  ),
                  const Spacer(),
                  TextButton.icon(
                    onPressed: _centerMap,
                    icon: const Icon(Icons.center_focus_strong, size: 14),
                    label: const Text('Centrar', style: TextStyle(fontSize: 12)),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      minimumSize: Size.zero,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _latCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Latitud',
                        hintText: 'Ej: 18.486138',
                        isDense: true,
                        prefixIcon: Icon(Icons.swap_vert, size: 16),
                      ),
                      keyboardType: const TextInputType.numberWithOptions(
                        signed: true,
                        decimal: true,
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[-0-9.]')),
                      ],
                      onChanged: (v) {
                        final parsed = double.tryParse(v);
                        if (parsed != null) {
                          setState(() => _lat = parsed);
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: _lngCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Longitud',
                        hintText: 'Ej: -69.931212',
                        isDense: true,
                        prefixIcon: Icon(Icons.swap_horiz, size: 16),
                      ),
                      keyboardType: const TextInputType.numberWithOptions(
                        signed: true,
                        decimal: true,
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[-0-9.]')),
                      ],
                      onChanged: (v) {
                        final parsed = double.tryParse(v);
                        if (parsed != null) {
                          setState(() => _lng = parsed);
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton.icon(
                    onPressed: _applyManualCoords,
                    icon: const Icon(Icons.search, size: 14),
                    label: const Text('Ir', style: TextStyle(fontSize: 13)),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),

        // Mapa interactivo
        Container(
          height: 340,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border, width: 1.5),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Stack(
              children: [
                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: LatLng(_lat, _lng),
                    initialZoom: _isEdit ? 14 : _defaultZoom,
                    onTap: _onMapTap,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.cabin.admin',
                    ),
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: LatLng(_lat, _lng),
                          width: 44,
                          height: 44,
                          child: GestureDetector(
                            onTap: _centerMap,
                            child: const Icon(
                              Icons.location_pin,
                              color: AppColors.secondary,
                              size: 44,
                              shadows: [
                                Shadow(
                                  color: Colors.black38,
                                  blurRadius: 8,
                                  offset: Offset(0, 3),
                                )
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                // Overlay de instrucciones (solo nuevo lugar)
                if (!_isEdit)
                  Positioned(
                    top: 10,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.65),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.touch_app, color: Colors.white, size: 14),
                            SizedBox(width: 5),
                            Text(
                              'Toca el mapa para ubicar el lugar',
                              style: TextStyle(color: Colors.white, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                // Coordenadas actuales en la esquina inferior
                Positioned(
                  bottom: 10,
                  left: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.60),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${_lat.toStringAsFixed(5)}, ${_lng.toStringAsFixed(5)}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ),
                ),

                // Botón zoom in/out
                Positioned(
                  right: 10,
                  bottom: 40,
                  child: Column(
                    children: [
                      _mapBtn(Icons.add, () {
                        final zoom = _mapController.camera.zoom;
                        _mapController.move(
                            _mapController.camera.center, zoom + 1);
                      }),
                      const SizedBox(height: 4),
                      _mapBtn(Icons.remove, () {
                        final zoom = _mapController.camera.zoom;
                        _mapController.move(
                            _mapController.camera.center, zoom - 1);
                      }),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            const Icon(Icons.info_outline, size: 13, color: AppColors.textHint),
            const SizedBox(width: 4),
            const Expanded(
              child: Text(
                'Toca el mapa para mover el pin · También puedes escribir las coordenadas arriba',
                style: TextStyle(fontSize: 11, color: AppColors.textHint),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _mapBtn(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(6),
          boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4)],
        ),
        child: Icon(icon, size: 18, color: Colors.black87),
      ),
    );
  }

  Widget _buildSidePanel() {
    return Column(
      children: [
        // ── Fotos ───────────────────────────────────────────────────
        _section('Fotos', [
          Row(
            children: [
              const Icon(Icons.photo_library_outlined,
                  size: 14, color: AppColors.textHint),
              const SizedBox(width: 6),
              Text(
                '${_existingPhotos.length + _newPhotoBytes.length}/${AppConfig.maxPlacePhotos} fotos',
                style: const TextStyle(
                    color: AppColors.textSecondary, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ..._existingPhotos.map((url) => _photoThumb(
                    child: Image.network(url,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                            const Icon(Icons.broken_image)),
                    onRemove: () =>
                        setState(() => _existingPhotos.remove(url)),
                  )),
              ..._newPhotoBytes.map((bytes) => _photoThumb(
                    child: Image.memory(bytes, fit: BoxFit.cover),
                    onRemove: () =>
                        setState(() => _newPhotoBytes.remove(bytes)),
                  )),
              if (_existingPhotos.length + _newPhotoBytes.length <
                  AppConfig.maxPlacePhotos)
                GestureDetector(
                  onTap: _pickImages,
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.07),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                          color:
                              AppColors.primary.withValues(alpha: 0.35)),
                    ),
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add_photo_alternate_outlined,
                            color: AppColors.primary, size: 24),
                        SizedBox(height: 4),
                        Text('Agregar',
                            style: TextStyle(
                                fontSize: 10, color: AppColors.primary)),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ]),
        const SizedBox(height: 16),

        // ── Configuración ────────────────────────────────────────────
        _section('Configuración', [
          SwitchListTile(
            value: _isActive,
            onChanged: (v) => setState(() => _isActive = v),
            title: const Text('Activo', style: TextStyle(fontSize: 14)),
            subtitle: const Text('Visible en la app',
                style: TextStyle(
                    color: AppColors.textHint, fontSize: 12)),
            activeThumbColor: AppColors.success,
            dense: true,
          ),
          SwitchListTile(
            value: _isFeatured,
            onChanged: (v) => setState(() => _isFeatured = v),
            title: const Text('Destacado', style: TextStyle(fontSize: 14)),
            subtitle: const Text('Aparece primero en búsquedas',
                style: TextStyle(
                    color: AppColors.textHint, fontSize: 12)),
            activeThumbColor: AppColors.accent,
            dense: true,
          ),
          SwitchListTile(
            value: _is24h,
            onChanged: (v) => setState(() => _is24h = v),
            title: const Text('Abierto 24 horas',
                style: TextStyle(fontSize: 14)),
            subtitle: const Text('Muestra badge "24 hrs"',
                style: TextStyle(
                    color: AppColors.textHint, fontSize: 12)),
            activeThumbColor: AppColors.info,
            dense: true,
          ),
        ]),
        const SizedBox(height: 16),

        // ── Info de coordenadas ──────────────────────────────────────
        _section('Posición en el mapa', [
          _coordRow(Icons.swap_vert, 'Latitud', _lat.toStringAsFixed(6)),
          const SizedBox(height: 8),
          _coordRow(Icons.swap_horiz, 'Longitud', _lng.toStringAsFixed(6)),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _centerMap,
              icon: const Icon(Icons.center_focus_strong, size: 16),
              label: const Text('Ver en el mapa'),
            ),
          ),
        ]),
      ],
    );
  }

  Widget _coordRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.primary),
        const SizedBox(width: 8),
        Text(label,
            style: const TextStyle(
                fontSize: 12, color: AppColors.textSecondary)),
        const Spacer(),
        Text(value,
            style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                fontFamily: 'monospace')),
      ],
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
          Text(title,
              style: const TextStyle(
                  fontWeight: FontWeight.bold, fontSize: 15)),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _photoThumb(
      {required Widget child, required VoidCallback onRemove}) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: SizedBox(width: 80, height: 80, child: child),
        ),
        Positioned(
          top: 2,
          right: 2,
          child: GestureDetector(
            onTap: onRemove,
            child: Container(
              decoration: const BoxDecoration(
                  color: AppColors.error, shape: BoxShape.circle),
              child: const Icon(Icons.close, size: 16, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }
}
