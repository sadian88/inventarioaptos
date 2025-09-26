import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';

import '../models/apartment_inventory.dart';
import '../models/inventory_item.dart';
import '../models/inventory_section.dart';
import '../repository/inventory_repository.dart';
import '../services/pdf_exporter.dart';

class InventoryProvider extends ChangeNotifier {
  InventoryProvider({
    required InventoryRepository repository,
    required PdfExporter pdfExporter,
  })  : _repository = repository,
        _pdfExporter = pdfExporter;

  final InventoryRepository _repository;
  final PdfExporter _pdfExporter;

  bool _isLoading = false;
  String? _errorMessage;
  List<ApartmentInventory> _apartments = <ApartmentInventory>[];

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<ApartmentInventory> get apartments => List.unmodifiable(_apartments);

  Future<void> initialize() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final loaded = await _repository.loadApartments();
      if (loaded.isEmpty) {
        final defaultApartment =
            _repository.createDefaultApartment(name: 'Apartamento modelo');
        _apartments = <ApartmentInventory>[defaultApartment];
        await _repository.saveApartments(_apartments);
      } else {
        _apartments = loaded;
      }
    } catch (error, stackTrace) {
      _errorMessage = 'No fue posible cargar el inventario: $error';
      debugPrintStack(stackTrace: stackTrace);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  ApartmentInventory? getApartment(String id) {
    return _apartments.firstWhereOrNull((apartment) => apartment.id == id);
  }

  Future<void> addApartment({
    required String name,
    String? address,
  }) async {
    final apartment = _repository.createDefaultApartment(
      name: name,
      address: address,
    );
    _apartments = <ApartmentInventory>[..._apartments, apartment];
    await _persist();
  }

  Future<void> deleteApartment(String id) async {
    _apartments =
        _apartments.where((apartment) => apartment.id != id).toList();
    await _persist();
  }

  Future<void> updateApartment({
    required String id,
    required String name,
    String? address,
    String? notes,
  }) async {
    final index = _apartments.indexWhere((apartment) => apartment.id == id);
    if (index == -1) {
      return;
    }
    final apartment = _apartments[index];
    final updated = apartment.copyWith(
      name: name,
      address: address,
      notes: notes,
      updatedAt: DateTime.now(),
    );
    _apartments = <ApartmentInventory>[...
        _apartments.sublist(0, index),
        updated,
        ..._apartments.sublist(index + 1),
      ];
    await _persist();
  }

  Future<void> updateItemValues({
    required String apartmentId,
    required String itemId,
    required ItemCondition condition,
    String? notes,
  }) async {
    final apartmentIndex =
        _apartments.indexWhere((apartment) => apartment.id == apartmentId);
    if (apartmentIndex == -1) {
      return;
    }

    final apartment = _apartments[apartmentIndex];
    InventorySection? section;
    InventoryItem? currentItem;
    for (final candidate in apartment.sections) {
      final match =
          candidate.items.firstWhereOrNull((item) => item.id == itemId);
      if (match != null) {
        section = candidate;
        currentItem = match;
        break;
      }
    }

    if (section == null || currentItem == null) {
      return;
    }

    final updatedItem = currentItem.copyWith(
      condition: condition,
      notes: notes,
    );

    final updatedApartment = apartment.updateItem(updatedItem);
    _apartments = <ApartmentInventory>[...
        _apartments.sublist(0, apartmentIndex),
        updatedApartment,
        ..._apartments.sublist(apartmentIndex + 1),
      ];
    await _persist();
  }

  Future<String?> exportApartmentPdf(String apartmentId) async {
    final apartment = getApartment(apartmentId);
    if (apartment == null) {
      return null;
    }
    final file = await _pdfExporter.generate(apartment);
    return file.path;
  }

  Future<void> _persist() async {
    await _repository.saveApartments(_apartments);
    notifyListeners();
  }
}
