import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

import '../data/default_items.dart';
import '../models/apartment_inventory.dart';

class InventoryRepository {
  InventoryRepository({DefaultInventories? defaultInventories})
      : _defaultInventories = defaultInventories ?? DefaultInventories();

  final DefaultInventories _defaultInventories;
  static const String _fileName = 'apartments_inventory.json';

  Future<File> _inventoryFile() async {
    Directory directory;
    try {
      directory = await getApplicationDocumentsDirectory();
    } on MissingPluginException {
      directory = await getTemporaryDirectory();
    }

    final path = '${directory.path}/$_fileName';
    return File(path);
  }

  Future<List<ApartmentInventory>> loadApartments() async {
    final file = await _inventoryFile();

    if (!await file.exists()) {
      return <ApartmentInventory>[];
    }

    final raw = await file.readAsString();
    if (raw.trim().isEmpty) {
      return <ApartmentInventory>[];
    }

    final List<dynamic> decoded = json.decode(raw) as List<dynamic>;
    return decoded
        .map((dynamic element) =>
            ApartmentInventory.fromMap(element as Map<String, dynamic>))
        .toList();
  }

  Future<void> saveApartments(List<ApartmentInventory> apartments) async {
    final file = await _inventoryFile();
    if (!await file.exists()) {
      await file.create(recursive: true);
    }
    final encoded = json.encode(
      apartments.map((apartment) => apartment.toMap()).toList(),
    );
    await file.writeAsString(encoded, flush: true);
  }

  ApartmentInventory createDefaultApartment({
    String name = 'Nuevo apartamento',
    String? address,
  }) {
    return _defaultInventories.createTemplate(
      name: name,
      address: address,
    );
  }
}
