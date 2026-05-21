import 'dart:typed_data';
import 'package:flutter/material.dart';
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
  String _type = 'cabaña';
  String _city = '';
  String _state = '';
  double _lat = 23.6345;
  double _lng = -102.5528;
  bool _isActive = true;
  bool _isFeatured = false;
  List<String> _existingPhotos = [];
  List<Uint8List> _newPhotoBytes = [];
  final List<String> _amenities = [];
  final _mapController = MapController();

  bool get _isEdit => widget.placeId != null;

  static const _placeTypes = ['cabaña', 'motel', 'hotel', 'villa', 'bungalow', 'glamping', 'hostal', 'otro'];

  @override
  void initState() {
    super.initState();
    if (_isEdit) _loadPlace();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    _addressCtrl.dispose();
    _priceCtrl.dispose();
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
        _type = place.type;
        _city = place.city;
        _state = place.state;
        _lat = place.lat;
        _lng = place.lng;
        _isActive = place.isActive;
        _isFeatured = place.isFeatured;
        _existingPhotos = List.from(place.photos);
        _amenities.addAll(place.amenities);
        _loadingPlace = false;
      });
    }
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
    if (_city.isEmpty || _state.isEmpty) {
      _showError('Selecciona ciudad y estado');
      return;
    }
    setState(() => _loading = true);
    try {
      final newUrls = await _storage.uploadMultiple(
          _newPhotoBytes, AppConfig.storagePlaces, 'jpg');
      final allPhotos = [..._existingPhotos, ...newUrls];

      final data = {
        'name': _nameCtrl.text.trim(),
        'description': _descCtrl.text.trim(),
        'type': _type,
        'address': _addressCtrl.text.trim(),
        'city': _city,
        'state': _state,
        'geopoint': GeoPoint(_lat, _lng),
        'location': {'city': _city, 'state': _state},
        'photos': allPhotos,
        'amenities': _amenities,
        'pricePerNight': double.tryParse(_priceCtrl.text) ?? 0,
        'isActive': _isActive,
        'isFeatured': _isFeatured,
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

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: AppColors.error),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loadingPlace) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
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
                ],
              ),
              const SizedBox(height: 24),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 3, child: _buildMainForm()),
                  const SizedBox(width: 20),
                  Expanded(flex: 2, child: _buildSidePanel()),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  const Spacer(),
                  TextButton(
                    onPressed: () => context.go(AppRoutes.places),
                    child: const Text('Cancelar'),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: _loading ? null : _submit,
                    child: _loading
                        ? const SizedBox(
                            width: 20, height: 20,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : Text(_isEdit ? 'Guardar cambios' : 'Crear lugar'),
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
        _section('Información básica', [
          TextFormField(
            controller: _nameCtrl,
            decoration: const InputDecoration(labelText: 'Nombre del lugar'),
            validator: (v) => v == null || v.isEmpty ? 'Requerido' : null,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _type,
                  decoration: const InputDecoration(labelText: 'Tipo'),
                  dropdownColor: AppColors.card,
                  items: _placeTypes.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                  onChanged: (v) => setState(() => _type = v!),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  controller: _priceCtrl,
                  decoration: const InputDecoration(labelText: 'Precio por noche (MXN)', prefixText: '\$'),
                  keyboardType: TextInputType.number,
                  validator: (v) => v == null || v.isEmpty ? 'Requerido' : null,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _descCtrl,
            decoration: const InputDecoration(labelText: 'Descripción'),
            maxLines: 4,
            validator: (v) => v == null || v.isEmpty ? 'Requerido' : null,
          ),
        ]),
        const SizedBox(height: 16),
        _section('Ubicación', [
          TextFormField(
            controller: _addressCtrl,
            decoration: const InputDecoration(labelText: 'Dirección completa'),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  initialValue: _city,
                  decoration: const InputDecoration(labelText: 'Ciudad'),
                  onChanged: (v) => _city = v,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _state.isEmpty ? null : _state,
                  decoration: const InputDecoration(labelText: 'Estado'),
                  dropdownColor: AppColors.card,
                  isExpanded: true,
                  items: AppConfig.mexicoStates
                      .map((s) => DropdownMenuItem(value: s, child: Text(s, overflow: TextOverflow.ellipsis)))
                      .toList(),
                  onChanged: (v) => setState(() => _state = v ?? ''),
                  validator: (v) => v == null || v.isEmpty ? 'Requerido' : null,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            height: 280,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: LatLng(_lat, _lng),
                  initialZoom: 5,
                  onTap: (_, latlng) {
                    setState(() {
                      _lat = latlng.latitude;
                      _lng = latlng.longitude;
                    });
                  },
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
                        width: 40,
                        height: 40,
                        child: const Icon(Icons.location_pin, color: AppColors.secondary, size: 40),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Toca el mapa para establecer la ubicación  •  Lat: ${_lat.toStringAsFixed(4)}, Lng: ${_lng.toStringAsFixed(4)}',
            style: const TextStyle(fontSize: 11, color: AppColors.textHint),
          ),
        ]),
        const SizedBox(height: 16),
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
                    if (v) _amenities.add(a);
                    else _amenities.remove(a);
                  });
                },
                selectedColor: AppColors.primary.withValues(alpha: 0.2),
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

  Widget _buildSidePanel() {
    return Column(
      children: [
        _section('Fotos', [
          const Text('Sube hasta 10 fotos del lugar', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ..._existingPhotos.map((url) => _photoThumb(
                child: Image.network(url, fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const Icon(Icons.broken_image)),
                onRemove: () => setState(() => _existingPhotos.remove(url)),
              )),
              ..._newPhotoBytes.map((bytes) => _photoThumb(
                child: Image.memory(bytes, fit: BoxFit.cover),
                onRemove: () => setState(() => _newPhotoBytes.remove(bytes)),
              )),
              if (_existingPhotos.length + _newPhotoBytes.length < AppConfig.maxPlacePhotos)
                GestureDetector(
                  onTap: _pickImages,
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.primary.withValues(alpha: 0.3), style: BorderStyle.solid),
                    ),
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add_photo_alternate_outlined, color: AppColors.primary, size: 24),
                        SizedBox(height: 4),
                        Text('Agregar', style: TextStyle(fontSize: 10, color: AppColors.primary)),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ]),
        const SizedBox(height: 16),
        _section('Configuración', [
          SwitchListTile(
            value: _isActive,
            onChanged: (v) => setState(() => _isActive = v),
            title: const Text('Activo', style: TextStyle(fontSize: 14)),
            subtitle: const Text('Visible en la app', style: TextStyle(color: AppColors.textHint, fontSize: 12)),
            activeThumbColor: AppColors.success,
            dense: true,
          ),
          SwitchListTile(
            value: _isFeatured,
            onChanged: (v) => setState(() => _isFeatured = v),
            title: const Text('Destacado', style: TextStyle(fontSize: 14)),
            subtitle: const Text('Aparece primero en búsquedas', style: TextStyle(color: AppColors.textHint, fontSize: 12)),
            activeThumbColor: AppColors.accent,
            dense: true,
          ),
        ]),
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
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _photoThumb({required Widget child, required VoidCallback onRemove}) {
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
              decoration: const BoxDecoration(color: AppColors.error, shape: BoxShape.circle),
              child: const Icon(Icons.close, size: 16, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }
}
