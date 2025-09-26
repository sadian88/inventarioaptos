import 'dart:convert';

import 'inventory_item.dart';
import 'inventory_section.dart';

class ApartmentInventory {
  const ApartmentInventory({
    required this.id,
    required this.name,
    required this.sections,
    required this.createdAt,
    required this.updatedAt,
    this.address,
    this.notes,
  });

  final String id;
  final String name;
  final String? address;
  final String? notes;
  final List<InventorySection> sections;
  final DateTime createdAt;
  final DateTime updatedAt;

  ApartmentInventory copyWith({
    String? id,
    String? name,
    String? address,
    String? notes,
    List<InventorySection>? sections,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ApartmentInventory(
      id: id ?? this.id,
      name: name ?? this.name,
      address: address ?? this.address,
      notes: notes ?? this.notes,
      sections: sections ?? this.sections,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  ApartmentInventory updateItem(InventoryItem updatedItem) {
    final updatedSections = sections.map((section) {
      if (section.id != updatedItem.sectionId) {
        return section;
      }
      final items = section.items.map((item) {
        return item.id == updatedItem.id ? updatedItem : item;
      }).toList();
      return section.copyWith(items: items);
    }).toList();

    return copyWith(
      sections: updatedSections,
      updatedAt: DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'address': address,
      'notes': notes,
      'sections': sections.map((section) => section.toMap()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory ApartmentInventory.fromMap(Map<String, dynamic> map) {
    return ApartmentInventory(
      id: map['id'] as String,
      name: map['name'] as String,
      address: map['address'] as String?,
      notes: map['notes'] as String?,
      sections: (map['sections'] as List<dynamic>)
          .map((dynamic section) =>
              InventorySection.fromMap(section as Map<String, dynamic>))
          .toList(),
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt: DateTime.parse(map['updatedAt'] as String),
    );
  }

  String toJson() => json.encode(toMap());

  factory ApartmentInventory.fromJson(String source) =>
      ApartmentInventory.fromMap(json.decode(source) as Map<String, dynamic>);
}
