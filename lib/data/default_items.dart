import 'package:uuid/uuid.dart';

import '../models/apartment_inventory.dart';
import '../models/inventory_item.dart';
import '../models/inventory_section.dart';

class DefaultInventories {
  DefaultInventories({Uuid? uuid}) : _uuid = uuid ?? const Uuid();

  final Uuid _uuid;

  ApartmentInventory createTemplate({
    String name = 'Apartamento sin nombre',
    String? address,
  }) {
    final now = DateTime.now();
    final sections = buildSections();
    return ApartmentInventory(
      id: _uuid.v4(),
      name: name,
      address: address,
      sections: sections,
      notes: null,
      createdAt: now,
      updatedAt: now,
    );
  }

  List<InventorySection> buildSections() {
    return _sectionDefinitions.map((definition) {
      final sectionId = _uuid.v4();
      final items = (definition['items'] as List<String>)
          .map(
            (label) => InventoryItem(
              id: _uuid.v4(),
              label: label,
              sectionId: sectionId,
            ),
          )
          .toList();
      return InventorySection(
        id: sectionId,
        name: definition['name'] as String,
        description: definition['description'] as String?,
        items: items,
      );
    }).toList();
  }
}

const List<Map<String, Object?>> _sectionDefinitions = <Map<String, Object?>>[
  <String, Object?>{
    'name': 'Acceso principal',
    'items': <String>[
      'Puerta principal',
      'Cerradura puerta ppal',
      'Pisos',
      'Paredes',
      'Cielos',
      'Vidrios',
      'Tomas eléctricos',
      'Tomas de televisión',
      'Tomas telefónicos',
      'Luces/Lámparas',
      'Interruptores',
      'Ventanal',
      'Persiana/Blackout',
      'Malla de seguridad',
    ],
  },
  <String, Object?>{
    'name': 'Baño social',
    'items': <String>[
      'Puerta',
      'Cerradura puerta',
      'Mesón',
      'Mueble',
      'Paredes',
      'Pisos',
      'Sanitario',
      'Lavamanos',
      'Cabina baño',
      'Ducha',
      'Espejo',
      'Mueble superior',
      'Incrustaciones de baño',
      'Toma',
    ],
  },
  <String, Object?>{
    'name': 'Área cocina',
    'items': <String>[
      'Muebles',
      'Mesón',
      'Grifo lavaplatos',
      'Estufa',
      'Campana extractora',
      'Pisos',
      'Paredes',
      'Barra americana',
      'Mueble superior barra',
      'Extractor',
    ],
  },
  <String, Object?>{
    'name': 'Área de labores',
    'items': <String>[
      'Lavadero',
      'Paredes',
      'Pisos',
      'Calentador',
      'Tendedero de ropa',
      'Mueble',
      'Puerta divisoria color café',
    ],
  },
  <String, Object?>{
    'name': 'Hall de alcobas',
    'items': <String>[
      'Pisos',
      'Paredes',
      'Luces/Lámparas',
    ],
  },
  <String, Object?>{
    'name': 'Habitación principal',
    'items': <String>[
      'Puerta',
      'Cerradura',
      'Pisos',
      'Paredes',
      'Cielos',
      'Clóset',
      'Interruptores',
      'Tomas eléctricos',
      'Luces/Lámparas',
      'Ventana',
      'Persiana/Blackout',
      'Malla de seguridad',
      'Entrepaño',
    ],
  },
  <String, Object?>{
    'name': 'Baño habitación principal',
    'items': <String>[
      'Puerta',
      'Cerradura puerta',
      'Mesón',
      'Mueble',
      'Paredes',
      'Pisos',
      'Sanitario',
      'Lavamanos',
      'Cabina baño',
      'Ducha',
      'Espejo',
      'Mueble superior',
      'Incrustaciones de baño',
      'Toma',
    ],
  },
  <String, Object?>{
    'name': 'Habitación auxiliar 1',
    'items': <String>[
      'Puerta',
      'Cerradura',
      'Pisos',
      'Paredes',
      'Cielos',
      'Clóset',
      'Interruptores',
      'Tomas eléctricos',
      'Luces/Lámparas',
      'Ventana',
      'Persiana/Blackout',
      'Malla de seguridad',
      'Repisa flotante',
    ],
  },
  <String, Object?>{
    'name': 'Habitación auxiliar 2',
    'items': <String>[
      'Puerta',
      'Cerradura',
      'Pisos',
      'Paredes',
      'Cielos',
      'Clóset',
      'Interruptores',
      'Tomas eléctricos',
      'Luces/Lámparas',
      'Ventana',
      'Persiana/Blackout',
      'Malla de seguridad',
      'Mueble adicional',
    ],
  },
];
